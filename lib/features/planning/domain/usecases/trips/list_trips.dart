//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/usecases/trips/list_trips.dart
// Author : Morice
//---------------------------------------------------------------------------


import '../../entities/trip.dart';
import '../../repositories/trip_repository.dart';

class ListTrips {
  final TripRepository repo;
  ListTrips(this.repo);

  Future<List<Trip>> call() => repo.listTrips();
}
