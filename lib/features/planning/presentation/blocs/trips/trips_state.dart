//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/blocs/trips/trips_state.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:equatable/equatable.dart';
import '../../../domain/entities/trip.dart';

enum TripCreateStatus { idle, submitting, success, failure }
enum TripFetchStatus  { initial, loading, ready, failure }

class TripsState extends Equatable {
  final List<Trip> trips;
  final TripCreateStatus createStatus;
  final TripFetchStatus fetchStatus;
  final String? error;

  const TripsState({
    this.trips = const [],
    this.createStatus = TripCreateStatus.idle,
    this.fetchStatus = TripFetchStatus.initial,
    this.error,
  });

  TripsState copyWith({
    List<Trip>? trips,
    TripCreateStatus? createStatus,
    TripFetchStatus? fetchStatus,
    String? error,
  }) =>
      TripsState(
        trips: trips ?? this.trips,
        createStatus: createStatus ?? this.createStatus,
        fetchStatus: fetchStatus ?? this.fetchStatus,
        error: error,
      );

  @override
  List<Object?> get props => [trips, createStatus, fetchStatus, error];
}


