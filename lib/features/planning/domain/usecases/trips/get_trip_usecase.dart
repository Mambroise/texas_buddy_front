//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/usecases/trips/get_trip_usecase.dart
// Author : Morice
//---------------------------------------------------------------------------

import '../../repositories/trip_repository.dart';
import '../../entities/trip.dart';

class GetTripUseCase {
  final TripRepository repo;
  GetTripUseCase(this.repo);

  Future<Trip> call(int id) {
    return repo.getTripById(id);
  }
}
