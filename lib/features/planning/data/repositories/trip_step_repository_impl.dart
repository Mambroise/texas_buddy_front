//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : data/repositories/trip_step_repository_impl.dart
// Author : Morice
//---------------------------------------------------------------------------

import '../../domain/entities/trip_step.dart';
import '../../domain/repositories/trip_step_repository.dart';
import '../datasources/remote/trip_step_remote_datasource.dart';

class TripStepRepositoryImpl implements TripStepRepository {
  final TripStepRemoteDataSource remote;
  TripStepRepositoryImpl(this.remote);

  @override
  Future<TripStep> create({
    required int tripId,
    required int tripDayId,
    required String targetType,   // "activity" | "event"
    required int targetId,        // ⚠️ int, pas String
    required String targetName,   // UI only
    required int startHour,
    required int startMinute,
    required int estimatedDurationMinutes,
    String? primaryIcon,
    List<String> otherIcons = const [],
    String? placeId,
    double? latitude,
    double? longitude,
    int? travelDurationMinutes,
    int? travelDistanceMeters,
    String travelMode = 'driving',
  }) async {
    // Normalise le type
    final kind = targetType.trim().toLowerCase();

    int? activityId;
    int? eventId;
    if (kind == 'activity') {
      activityId = targetId;
    } else if (kind == 'event') {
      eventId = targetId;
    }

    // HH:MM:SS
    final startTime =
        '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';

    // ✅ On n’envoie que les IDs au backend (pas le title)
    final created = await remote.create(
      tripId: tripId,
      tripDayId: tripDayId,
      startTime: startTime,
      estimatedDurationMinutes: estimatedDurationMinutes,
      travelMode: travelMode,
      travelDurationMinutes: travelDurationMinutes,
      travelDistanceMeters: travelDistanceMeters,
      activityId: activityId,
      eventId: eventId,
    );

    return created;
  }
}
