//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/usecases/trips/delete_trip.dart
// Author : Morice
//---------------------------------------------------------------------------


import '../../repositories/trip_repository.dart';

class DeleteTrip {
  final TripRepository repo;
  DeleteTrip(this.repo);

  Future<void> call(int id) => repo.deleteTrip(id);
}
