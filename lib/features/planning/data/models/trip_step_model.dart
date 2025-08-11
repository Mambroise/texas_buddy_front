//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/models/trip_step_model.dart
// Author : Morice
//-------------------------------------------------------------------------


/// TripStep Model
class TripStepModel {
  final int? id;
  final int tripDayId;
  final int? activityId;
  final int? eventId;
  final String startTime; // stored as ISO string 'HH:mm:ss'
  final int estimatedDurationMinutes;
  final String travelMode;
  final int travelDurationMinutes;
  final int travelDistanceMeters;
  final String? endTime;
  final String? notes;
  final int position;

  TripStepModel({
    this.id,
    required this.tripDayId,
    this.activityId,
    this.eventId,
    required this.startTime,
    required this.estimatedDurationMinutes,
    required this.travelMode,
    required this.travelDurationMinutes,
    required this.travelDistanceMeters,
    this.endTime,
    this.notes,
    this.position = 0,
  });

  factory TripStepModel.fromMap(Map<String, dynamic> map) {
    return TripStepModel(
      id: map['id'] as int?,
      tripDayId: map['trip_day_id'] as int,
      activityId: map['activity_id'] as int?,
      eventId: map['event_id'] as int?,
      startTime: map['start_time'] as String,
      estimatedDurationMinutes: map['estimated_duration_minutes'] as int,
      travelMode: map['travel_mode'] as String,
      travelDurationMinutes: map['travel_duration_minutes'] as int,
      travelDistanceMeters: map['travel_distance_meters'] as int,
      endTime: map['end_time'] as String?,
      notes: map['notes'] as String?,
      position: map['position'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'trip_day_id': tripDayId,
      'activity_id': activityId,
      'event_id': eventId,
      'start_time': startTime,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'travel_mode': travelMode,
      'travel_duration_minutes': travelDurationMinutes,
      'travel_distance_meters': travelDistanceMeters,
      'end_time': endTime,
      'notes': notes,
      'position': position,
    };
  }
}