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
    final kind = targetType.trim().toLowerCase();

    int? activityId;
    int? eventId;
    if (kind == 'activity') {
      activityId = targetId;
    } else if (kind == 'event') {
      eventId = targetId;
    }

    final startTime =
        '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';

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

  @override
  Future<void> delete(int stepId) async {
    await remote.delete(stepId: stepId);
  }

  @override
  Future<TripStep> update({
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
  }) async {
    int? activityId;
    int? eventId;

    if (targetType != null && targetId != null) {
      final kind = targetType.trim().toLowerCase();
      if (kind == 'activity') {
        activityId = targetId;
        eventId = null;
      } else if (kind == 'event') {
        eventId = targetId;
        activityId = null;
      }
    }

    String? startTime;
    if (startHour != null && startMinute != null) {
      startTime =
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';
    }

    final updated = await remote.update(
      stepId: id,
      tripDayId: tripDayId,
      startTime: startTime,
      estimatedDurationMinutes: estimatedDurationMinutes,
      travelMode: travelMode,
      travelDurationMinutes: travelDurationMinutes,
      travelDistanceMeters: travelDistanceMeters,
      activityId: activityId,
      eventId: eventId,
    );

    return updated;
  }
}
