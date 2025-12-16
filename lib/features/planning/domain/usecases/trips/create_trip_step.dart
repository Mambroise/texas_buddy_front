//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/usecases/trips/create_trip_step.dart
// Author : Morice
//---------------------------------------------------------------------------


import '../../repositories/trip_step_repository.dart';
import '../../entities/trip_step.dart';

class CreateTripStep {
  final TripStepRepository repo;
  CreateTripStep(this.repo);

  Future<TripStep> execute({
    required int tripId,
    required int tripDayId,
    required int startHour,
    required int startMinute,
    required int estimatedDurationMinutes,
    required String targetType, // "activity" | "event"
    required int targetId,
    required String targetName,
    String? primaryIcon,
    List<String> otherIcons = const [],
    String? placeId,
    double? latitude,
    double? longitude,
    int? travelDurationMinutes,
    int? travelDistanceMeters,
    String travelMode = 'driving',
  }) {
    return repo.create(
      tripId: tripId,
      tripDayId: tripDayId,
      startHour: startHour,
      startMinute: startMinute,
      estimatedDurationMinutes: estimatedDurationMinutes,
      targetType: targetType,
      targetId: targetId,
      targetName: targetName,
      primaryIcon: primaryIcon,
      otherIcons: otherIcons,
      placeId: placeId,
      latitude: latitude,
      longitude: longitude,
      travelDurationMinutes: travelDurationMinutes,
      travelDistanceMeters: travelDistanceMeters,
      travelMode: travelMode,
    );
  }
}
