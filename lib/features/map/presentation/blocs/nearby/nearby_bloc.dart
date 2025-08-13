//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/blocs/nearby/nearby_bloc.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';
import 'package:texas_buddy/features/map/domain/usecases/get_nearby.dart';

part 'nearby_event.dart';
part 'nearby_state.dart';

class NearbyBloc extends Bloc<NearbyEvent, NearbyState> {
  final GetNearby getNearby;

  NearbyBloc({required this.getNearby}) : super(const NearbyState.initial()) {
    on<NearbyRequested>(_onRequested);
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
}
