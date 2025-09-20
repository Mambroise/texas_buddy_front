//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/datasources/remote/trip_step_remote_datasource.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:dio/dio.dart';
import '../../../domain/entities/trip_step.dart';
import '../../dtos/trip_step_dto.dart';

abstract class TripStepRemoteDataSource {
  Future<TripStep> create({
    required int tripId,
    required int tripDayId,
    required String? targetType, // "activity" or "event"
    required int? activityId,
    required int? eventId,
    required String startTime, // "HH:MM:SS" or "HH:MM"
    required int estimatedDurationMinutes,
    String? travelMode,
    int? travelDurationMinutes,
    int? travelDistanceMeters,
  });

// plus tard: list, delete, move...
}

class TripStepRemoteDataSourceImpl implements TripStepRemoteDataSource {
  final Dio dio;
  TripStepRemoteDataSourceImpl(this.dio);

  static const _base = 'planners/trip-steps/';

  @override
  Future<TripStep> create({
    required int tripId,
    required int tripDayId,
    required String? targetType,
    required int? activityId,
    required int? eventId,
    required String startTime,
    required int estimatedDurationMinutes,
    String? travelMode,
    int? travelDurationMinutes,
    int? travelDistanceMeters,
  }) async {
    final body = <String, dynamic>{
      'trip_day': tripDayId,
      'start_time': startTime,
      'estimated_duration_minutes': estimatedDurationMinutes,
    };
    if (activityId != null) body['activity_id'] = activityId;
    if (eventId != null) body['event_id'] = eventId;
    if (travelMode != null) body['travel_mode'] = travelMode;
    if (travelDurationMinutes != null) body['travel_duration_minutes'] = travelDurationMinutes;
    if (travelDistanceMeters != null) body['travel_distance_meters'] = travelDistanceMeters;

    final resp = await dio.post(_base, data: body);
    final dto = TripStepDto.fromJson(resp.data as Map<String, dynamic>);
    return dto.toEntity();
  }
}
