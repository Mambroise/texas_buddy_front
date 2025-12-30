//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/blocs/detail/detail_panel_bloc.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/detail_models.dart';
import '../../../domain/usecases/get_activity_detail.dart';
import '../../../domain/usecases/get_event_detail.dart';

// ✅ NEW: travel (backend google)
import 'package:texas_buddy/features/planning/domain/usecases/travel/compute_travel.dart';

// ✅ NEW: focus
import '../../cubits/map_focus_cubit.dart';

part 'detail_panel_event.dart';
part 'detail_panel_state.dart';

class DetailPanelBloc extends Bloc<DetailPanelEvent, DetailPanelState> {
  final GetActivityDetail getActivity;
  final GetEventDetail getEvent;

  /// ✅ NEW
  final ComputeTravel computeTravel;
  final MapFocusCubit mapFocusCubit;

  DetailPanelBloc({
    required this.getActivity,
    required this.getEvent,
    required this.computeTravel,
    required this.mapFocusCubit,
  }) : super(const DetailHidden()) {
    on<DetailCloseRequested>((e, emit) => emit(const DetailHidden()));

    on<DetailOpenRequested>((e, emit) async {
      emit(DetailLoading(anchor: e.anchor));

      if (e.type == DetailType.activity) {
        final res = e.byPlaceId
            ? await getActivity.byPlace(e.idOrPlaceId)
            : await getActivity.byId(e.idOrPlaceId);

        await res.fold(
              (fail) async => emit(DetailError(message: fail.message)),
              (entity) async {
            final travelPack = await _computeTravelForEntity(
              destLat: entity.latitude,
              destLng: entity.longitude,
              lang: e.lang,
            );

            emit(DetailActivityLoaded(
              entity: entity,
              travel: travelPack?.$1,
              focusSource: travelPack?.$2,
              anchor: e.anchor,
            ));
          },
        );
      } else {
        final res = e.byPlaceId
            ? await getEvent.byPlace(e.idOrPlaceId)
            : await getEvent.byId(e.idOrPlaceId);

        await res.fold(
              (fail) async => emit(DetailError(message: fail.message)),
              (entity) async {
            final travelPack = await _computeTravelForEntity(
              destLat: entity.latitude,
              destLng: entity.longitude,
              lang: e.lang,
            );

            emit(DetailEventLoaded(
              entity: entity,
              travel: travelPack?.$1,
              focusSource: travelPack?.$2,
              anchor: e.anchor,
            ));
          },
        );
      }
    });
  }

  bool _validCoords(double lat, double lng) =>
      lat.abs() > 0.0001 && lng.abs() > 0.0001;

  /// Retourne (TravelInfo, MapFocusSource) ou null si pas possible
  Future<(TravelInfo, MapFocusSource)?> _computeTravelForEntity({
    required double destLat,
    required double destLng,
    String? lang,
  }) async {
    if (!_validCoords(destLat, destLng)) return null;

    final focus = mapFocusCubit.state;
    if (focus == null) return null;

    final originLat = focus.latitude;
    final originLng = focus.longitude;
    if (!_validCoords(originLat, originLng)) return null;

    try {
      final (minutes, meters) = await computeTravel.call(
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
        mode: 'driving',
        lang: lang,
      );

      return (TravelInfo(minutes: minutes, meters: meters), focus.source);
    } catch (_) {
      // On n’affiche juste pas la ligne travel si erreur
      return null;
    }
  }
}
