//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/blocs/nearby/nearby_bloc.dart
// Author : Morice
//---------------------------------------------------------------------------


// features/map/presentation/blocs/nearby/nearby_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';
import 'package:texas_buddy/features/map/domain/usecases/get_nearby.dart';
import 'package:texas_buddy/features/map/domain/usecases/get_nearby_in_bounds.dart';

part 'nearby_event.dart';
part 'nearby_state.dart';

class NearbyBloc extends Bloc<NearbyEvent, NearbyState> {
  final GetNearby getNearby;                   // legacy (liste/timeline)
  final GetNearbyInBounds getNearbyInBounds;   // nouveau pour la carte

  NearbyBloc({
    required this.getNearby,
    required this.getNearbyInBounds,
  }) : super(const NearbyState.initial()) {
    on<NearbyRequested>(_onRequested);
    on<NearbyRequestedBounds>(_onRequestedBounds);
  }

  int _capForZoom(int zoom) {
    if (zoom <= 8)  return 50;
    if (zoom <= 11) return 100;
    if (zoom <= 13) return 150;
    if (zoom <= 15) return 200;
    return 300;
  }

  Future<void> _onRequested(NearbyRequested e, Emitter<NearbyState> emit) async {
    emit(state.copyWith(status: NearbyStatus.loading));
    try {
      final items = await getNearby(
        latitude: e.latitude,
        longitude: e.longitude,
        radiusKm: e.radiusKm,
        limit: e.limit,
      );
      emit(state.copyWith(status: NearbyStatus.loaded, items: items));
    } catch (err) {
      emit(state.copyWith(status: NearbyStatus.error, error: err.toString()));
    }
  }

  Future<void> _onRequestedBounds(
      NearbyRequestedBounds e,
      Emitter<NearbyState> emit,
      ) async {
    emit(state.copyWith(status: NearbyStatus.loading));
    try {
      // centre (utile pour tri distance côté serveur ou client)
      final centerLat = (e.north + e.south) / 2.0;
      final centerLng = (e.east + e.west) / 2.0;

      // si e.limit <= 0 on calcule un cap par zoom
      final cap = (e.limit > 0) ? e.limit : _capForZoom(e.zoom);

      final items = await getNearbyInBounds(
        north: e.north,
        south: e.south,
        east:  e.east,
        west:  e.west,
        zoom:  e.zoom,
        categoryKeys: e.categoryKeys,
        limit: cap,
        centerLat: centerLat,
        centerLng: centerLng,
      );

      emit(state.copyWith(status: NearbyStatus.loaded, items: items));
    } catch (err) {
      emit(state.copyWith(status: NearbyStatus.error, error: err.toString()));
    }
  }
}

