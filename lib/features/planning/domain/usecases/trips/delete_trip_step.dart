//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/usecases/trips/delete_trip_step.dart
// Author : Morice
//---------------------------------------------------------------------------

import '../../repositories/trip_step_repository.dart';

class DeleteTripStep {
  final TripStepRepository repository;
  DeleteTripStep(this.repository);

  Future<void> execute({required int stepId}) {
    return repository.delete(stepId);
  }
}
