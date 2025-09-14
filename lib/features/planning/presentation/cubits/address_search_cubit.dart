//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/blocs/address_search/address_search_cubit.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:texas_buddy/features/planning/domain/entities/address_suggestion.dart';
import 'package:texas_buddy/features/planning/domain/entities/trip.dart';

import 'package:texas_buddy/features/planning/domain/usecases/address_search/search_address_suggestions_usecase.dart';
import 'package:texas_buddy/features/planning/domain/usecases/address_search/select_address_usecase.dart';
import 'package:texas_buddy/features/planning/domain/usecases/trips/update_tripday_address_usecase.dart';
import 'package:texas_buddy/features/planning/domain/usecases/trips/get_trip_usecase.dart';

enum AddressSearchStatus { idle, loading, loaded, error, selecting, done }

class AddressSearchState extends Equatable {
  final String city;
  final String query;
  final AddressSearchStatus status;
  final List<AddressSuggestion> results;
  final String? errorMessage;

  const AddressSearchState({
    this.city = '',
    this.query = '',
    this.status = AddressSearchStatus.idle,
    this.results = const [],
    this.errorMessage,
  });

  AddressSearchState copyWith({
    String? city,
    String? query,
    AddressSearchStatus? status,
    List<AddressSuggestion>? results,
    String? errorMessage,
  }) =>
      AddressSearchState(
        city: city ?? this.city,
        query: query ?? this.query,
        status: status ?? this.status,
        results: results ?? this.results,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [city, query, status, results, errorMessage];
}

class AddressSearchCubit extends Cubit<AddressSearchState> {
  final SearchAddressSuggestionsUseCase _search;
  final SelectAddressUseCase _select;
  final UpdateTripDayAddressUseCase _updateTripDay;
  final GetTripUseCase _getTrip; // ✅ nouveau

  /// Callback optionnel pour pousser le Trip rafraîchi
  final void Function(Trip trip)? onTripRefreshed;

  final String uiLang;

  AddressSearchCubit(
      this._search,
      this._select,
      this._updateTripDay,
      this._getTrip, {
        required this.uiLang,
        this.onTripRefreshed,
      }) : super(const AddressSearchState());

  final _debounce = Duration(milliseconds: 300);
  Timer? _timer;

  void setCity(String v) {
    emit(state.copyWith(city: v, results: []));
    _trigger();
  }

  void setQuery(String v) {
    emit(state.copyWith(query: v));
    _trigger();
  }

  void _trigger() {
    _timer?.cancel();
    final city = state.city.trim();
    final q = state.query.trim();
    if (city.isEmpty || q.length < 3) {
      emit(state.copyWith(status: AddressSearchStatus.idle, results: []));
      return;
    }
    _timer = Timer(_debounce, () async {
      emit(state.copyWith(status: AddressSearchStatus.loading));
      final either = await _search(
        SearchAddressParams(city: city, q: q, lang: uiLang, limit: 8),
      );
      either.fold(
            (err) => emit(state.copyWith(
          status: AddressSearchStatus.error,
          errorMessage: err.serverMessage ?? err.code.name,
        )),
            (items) => emit(state.copyWith(
          status: AddressSearchStatus.loaded,
          results: items,
        )),
      );
    });
  }

  /// Sélectionne une suggestion, met à jour le TripDay,
  /// puis rafraîchit le Trip courant pour que l'UI affiche l'adresse immédiatement.
  Future<void> selectSuggestion({
    required int tripId,      // ✅ ajouté
    required int tripDayId,
    required AddressSuggestion suggestion,
  }) async {
    emit(state.copyWith(status: AddressSearchStatus.selecting));

    int? cacheId = suggestion.addressCacheId;

    // Si pas d'id de cache, on demande au back de faire Place Details (+ upsert)
    if (cacheId == null) {
      final either = await _select(SelectAddressParams(
        placeId: suggestion.placeId,
        city: state.city.trim(),
        lang: uiLang,
      ));
      final res = either.fold((err) => null, (ok) => ok);
      if (res == null) {
        emit(state.copyWith(
          status: AddressSearchStatus.error,
          errorMessage: 'Failed to resolve address',
        ));
        return;
      }
      cacheId = res.addressCacheId;
    }

    // 1) PATCH TripDay
    final patched = await _updateTripDay(
      UpdateTripDayAddressParams(tripDayId: tripDayId, addressCacheId: cacheId),
    );

    await patched.fold(
          (err) async {
        emit(state.copyWith(
          status: AddressSearchStatus.error,
          errorMessage: err.serverMessage ?? err.code.name,
        ));
      },
          (_) async {
        try {
          // 2) Re-fetch du trip courant pour rafraîchir le wheel
          final trip = await _getTrip(tripId);
          // 3) Propager (optionnel) au parent/cubit principal
          onTripRefreshed?.call(trip);
          emit(state.copyWith(status: AddressSearchStatus.done));
        } catch (e) {
          // Même si le refresh échoue, on considère le patch OK
          emit(state.copyWith(
            status: AddressSearchStatus.done,
            // tu peux logguer l'erreur (Sentry) si besoin
          ));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
