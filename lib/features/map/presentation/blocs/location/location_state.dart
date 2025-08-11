//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/blocs/location/location_state.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:equatable/equatable.dart';
import 'package:texas_buddy/features/map/domain/entities/user_position.dart';

enum LocationStatus { initial, tracking, failure }

class LocationState extends Equatable {
  final LocationStatus status;
  final UserPosition? position;
  final bool recenterRequested;

  const LocationState({
    this.status = LocationStatus.initial,
    this.position,
    this.recenterRequested = false,
  });

  LocationState copyWith({
    LocationStatus? status,
    UserPosition? position,
    bool? recenterRequested,
  }) => LocationState(
    status: status ?? this.status,
    position: position ?? this.position,
    // ✅ garder la valeur existante si non précisé
    recenterRequested: recenterRequested ?? this.recenterRequested,
  );


  @override
  List<Object?> get props => [status, position, recenterRequested];
}