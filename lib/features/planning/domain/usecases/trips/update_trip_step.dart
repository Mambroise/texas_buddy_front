//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/usecases/trips/update_trip_step.dart
// Author : Morice
//---------------------------------------------------------------------------

import '../../entities/trip_step.dart';
import '../../repositories/trip_step_repository.dart';

class UpdateTripStep {
  final TripStepRepository _repo;
  const UpdateTripStep(this._repo);

  Future<TripStep> execute({
    required int id,
    int? tripDayId,
    int? startHour,
    int? startMinute,
    int? estimatedDurationMinutes,
    String? travelMode,
    int? travelDurationMinutes,
    int? travelDistanceMeters,
    String? targetType,
    int? targetId,
  }) {
    return _repo.update(
      id: id,
      tripDayId: tripDayId,
      startHour: startHour,
      startMinute: startMinute,
      estimatedDurationMinutes: estimatedDurationMinutes,
      travelMode: travelMode,
      travelDurationMinutes: travelDurationMinutes,
      travelDistanceMeters: travelDistanceMeters,
      targetType: targetType,
      targetId: targetId,
    );
  }

  // Optionnel : style callable
  Future<TripStep> call({
    required int id,
    int? tripDayId,
    int? startHour,
    int? startMinute,
    int? estimatedDurationMinutes,
    String? travelMode,
    int? travelDurationMinutes,
    int? travelDistanceMeters,
    String? targetType,
    int? targetId,
  }) =>
      execute(
        id: id,
        tripDayId: tripDayId,
        startHour: startHour,
        startMinute: startMinute,
        estimatedDurationMinutes: estimatedDurationMinutes,
        travelMode: travelMode,
        travelDurationMinutes: travelDurationMinutes,
        travelDistanceMeters: travelDistanceMeters,
        targetType: targetType,
        targetId: targetId,
      );
}
