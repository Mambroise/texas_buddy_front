//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/usecases/trips/create_trip_step.dart
// Author : Morice
//---------------------------------------------------------------------------


// lib/features/planning/domain/usecases/trips/create_trip_step.dart

import '../../entities/trip_step.dart';
import '../../repositories/trip_step_repository.dart';

class CreateTripStep {
  final TripStepRepository repo;
  CreateTripStep(this.repo);

  Future<TripStep> execute({
    required int tripId,
    required int tripDayId,
    required int startHour,
    required int startMinute,
    required int estimatedDurationMinutes,
    required String targetType,
    required int targetId,
    required String targetName,
    String? primaryIcon,
    List<String> otherIcons = const [],
    String? placeId,
    double? latitude,
    double? longitude,
  }) {
    return repo.create(
      tripId: tripId,
      tripDayId: tripDayId,
      targetType: targetType,
      targetId: targetId,
      targetName: targetName,
      startHour: startHour,
      startMinute: startMinute,
      estimatedDurationMinutes: estimatedDurationMinutes,
      primaryIcon: primaryIcon,
      otherIcons: otherIcons,
      placeId: placeId,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
