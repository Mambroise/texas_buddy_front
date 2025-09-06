//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/cubits/trips_cubit.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter_bloc/flutter_bloc.dart';

// ⚠️ On préfixe les entities pour éviter tout conflit de nom (TripCreate)
import '../../domain/entities/trip.dart' as ent;

// Usecases existants
import '../../domain/usecases/trips/create_trip.dart';
import '../../domain/usecases/trips/list_trips.dart';
import '../../domain/usecases/trips/delete_trip.dart';
import '../../domain/usecases/trips/update_trip.dart';

// State UI
import '../blocs/trips/trips_state.dart';

// Repo pour getTripById (trip détaillé days+steps)
import '../../domain/repositories/trip_repository.dart';

class TripsCubit extends Cubit<TripsState> {
  final CreateTrip createTripUsecase;
  final ListTrips listTripsUsecase;
  final DeleteTrip deleteTripUsecase;
  final UpdateTrip updateTripUsecase;

  // ✅ NEW: pour récupérer un Trip détaillé
  final TripRepository tripRepository;

  TripsCubit({
    required this.createTripUsecase,
    required this.listTripsUsecase,
    required this.deleteTripUsecase,
    required this.updateTripUsecase,
    required this.tripRepository, // <-- injecte le repo
  }) : super(const TripsState());

  Future<void> fetchAll({bool force = false}) async {
    if (!force && state.fetchStatus == TripFetchStatus.ready) return;
    emit(state.copyWith(fetchStatus: TripFetchStatus.loading, error: null));
    try {
      final items = await listTripsUsecase();
      emit(state.copyWith(trips: items, fetchStatus: TripFetchStatus.ready));
    } catch (e) {
      emit(state.copyWith(fetchStatus: TripFetchStatus.failure, error: e.toString()));
    }
  }

  Future<void> create({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required int adults,
    required int children,
  }) async {
    emit(state.copyWith(createStatus: TripCreateStatus.submitting, error: null));
    try {
      final trip = await createTripUsecase(
        // ✅ utiliser la classe ent.TripCreate du domaine
        ent.TripCreate(
          title: title,
          startDate: startDate,
          endDate: endDate,
          adults: adults,
          children: children,
        ),
      );

      final updated = List<ent.Trip>.from(state.trips)..insert(0, trip);
      emit(state.copyWith(trips: updated, createStatus: TripCreateStatus.success));
    } catch (e) {
      emit(state.copyWith(createStatus: TripCreateStatus.failure, error: e.toString()));
    } finally {
      emit(state.copyWith(createStatus: TripCreateStatus.idle));
    }
  }

  Future<bool> delete(int id) async {
    try {
      await deleteTripUsecase(id);
      final updated = List<ent.Trip>.from(state.trips)..removeWhere((t) => t.id == id);
      emit(state.copyWith(trips: updated));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update({
    required int id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    int? adults,
    int? children,
  }) async {
    try {
      final updatedTrip = await updateTripUsecase(
        id: id,
        title: title,
        startDate: startDate,
        endDate: endDate,
        adults: adults,
        children: children,
      );

      final list = List<ent.Trip>.from(state.trips);
      final idx = list.indexWhere((t) => t.id == id);
      if (idx != -1) list[idx] = updatedTrip;
      emit(state.copyWith(trips: list));
      return true;
    } catch (_) {
      return false;
    }
  }

  // ✅ NEW: pour alimenter la timeline avec un trip détaillé (days + steps)
  Future<ent.Trip> fetchTripDetail(int id) async {
    return await tripRepository.getTripById(id);
  }
}
