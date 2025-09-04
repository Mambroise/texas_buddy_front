//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/usecases/create_trip.dart
// Author : Morice
//---------------------------------------------------------------------------


import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class CreateTrip {
  final TripRepository repo;
  CreateTrip(this.repo);

  Future<Trip> call(TripCreate input) => repo.createTrip(input);
}
