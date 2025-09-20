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
    required String targetType,
    required int targetId,
    required String targetName,
    required int startHour,
    required int startMinute,
    required int estimatedDurationMinutes,
    String? primaryIcon,
    List<String> otherIcons = const [],
    String? placeId,
    double? latitude,
    double? longitude,
  }) async {
    // Mappe target -> activity_id/event_id pour l'API
    int? activityId;
    int? eventId;
    if (targetType == 'activity') {
      activityId = targetId;
    } else if (targetType == 'event') {
      eventId = targetId;
    }

    // Format start_time attendu par le backend : HH:MM:SS
    final startTime =
        '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}:00';

    // Appel au datasource remote qui renvoie déjà un TripStep (dto.toEntity())
    final created = await remote.create(
      tripId: tripId,
      tripDayId: tripDayId,
      targetType: targetType,
      activityId: activityId,
      eventId: eventId,
      startTime: startTime,
      estimatedDurationMinutes: estimatedDurationMinutes,
    );

    return created;
  }
}
