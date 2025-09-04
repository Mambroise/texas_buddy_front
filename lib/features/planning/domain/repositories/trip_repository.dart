//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/repositories/trip_repository.dart
// Author : Morice
//---------------------------------------------------------------------------


import '../entities/trip.dart';

abstract class TripRepository {
  Future<Trip> createTrip(TripCreate input);
// TODO: listTrips(), deleteTrip(id), etc.
}
