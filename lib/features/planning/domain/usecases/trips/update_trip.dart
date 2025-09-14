//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/usecases/trips/update_trip.dart
// Author : Morice
//---------------------------------------------------------------------------


import '../../entities/trip.dart';
import '../../repositories/trip_repository.dart';

class UpdateTrip {
  final TripRepository repo;
  UpdateTrip(this.repo);

  Future<Trip> call({
    required int id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    int? adults,
    int? children,
  }) {
    return repo.updateTrip(
      id: id,
      title: title,
      startDate: startDate,
      endDate: endDate,
      adults: adults,
      children: children,
    );
  }
}
