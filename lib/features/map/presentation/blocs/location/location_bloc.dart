//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/blocs/location/location_bloc.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/features/map/domain/usecases/get_user_position_stream.dart';
import 'package:texas_buddy/features/map/domain/entities/user_position.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GetUserPositionStream getUserPositionStream;
  StreamSubscription? _sub;

  LocationBloc(this.getUserPositionStream) : super(const LocationState()) {
    on<LocationStarted>(_onStarted);
    on<LocationRecenter>(_onRecenter);

    // ➕ nouveau: on stocke chaque position reçue
    on<_LocationNewPosition>((event, emit) {
      emit(state.copyWith(
        status: LocationStatus.tracking,
        position: event.position,
        // on consomme le recentrage (la Map bougera via le listener)
        recenterRequested: false,
      ));
    });
  }

  Future<void> _onStarted(LocationStarted event, Emitter<LocationState> emit) async {
    await _sub?.cancel();
    _sub = getUserPositionStream().listen(
          (pos) => add(_LocationNewPosition(pos)),
      onError: (_) => emit(state.copyWith(status: LocationStatus.failure)),
    );
  }

  void _onRecenter(LocationRecenter event, Emitter<LocationState> emit) {
    emit(state.copyWith(recenterRequested: true));
  }

  @override
  Future<void> close() { _sub?.cancel(); return super.close(); }
}

// Événement interne
class _LocationNewPosition extends LocationEvent {
  final UserPosition position; // ← typé
  const _LocationNewPosition(this.position);
  @override
  List<Object?> get props => [position];
}
