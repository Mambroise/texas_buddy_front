//---------------------------------------------------------------------------
// File   : features/planning/domain/entities/trip_step.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'step_target.dart';

class TripStep {
  final int id;
  final int startHour;   // 0..23
  final int startMinute; // 0..59
  final int? endHour;    // 0..23 (nullable si non renseigné)
  final int? endMinute;  // 0..59 (nullable)
  final int estimatedDurationMinutes;
  final StepTarget target;
  final String travelMode;
  final int travelDurationMinutes;
  final int travelDistanceMeters;
  final String notes;

  const TripStep({
    required this.id,
    required this.startHour,
    required this.startMinute,
    this.endHour,
    this.endMinute,
    required this.estimatedDurationMinutes,
    required this.target,
    this.travelMode = 'driving',
    this.travelDurationMinutes = 0,
    this.travelDistanceMeters = 0,
    this.notes = '',
  });
}
