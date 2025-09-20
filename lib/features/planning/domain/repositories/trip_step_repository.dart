//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/repositories/trip_step_repository.dart
// Author : Morice
//---------------------------------------------------------------------------


import '../entities/trip_step.dart';

abstract class TripStepRepository {
  /// Crée un TripStep côté backend et retourne l'entité complète.
  Future<TripStep> create({
    required int tripId,
    required int tripDayId,
    required String targetType, // "activity" | "event"
    required int targetId,
    required String targetName,
    required int startHour,
    required int startMinute,
    required int estimatedDurationMinutes,
    String? primaryIcon,
    List<String> otherIcons,
    String? placeId,
    double? latitude,
    double? longitude,
  });
}
