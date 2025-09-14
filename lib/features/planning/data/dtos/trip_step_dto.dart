//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : feztures/planning/data/dtos/trip_step_dto.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'activity_or_event_dto.dart';
import '../../domain/entities/trip_step.dart';
import '../../domain/entities/step_target.dart';

class TripStepDto {
  final int id;
  final String startTime; // "HH:MM:SS"
  final String? endTime;  // "HH:MM:SS"
  final int estimatedDurationMinutes;
  final ActivityOrEventDto? activity; // exclusif avec event
  final ActivityOrEventDto? event;    // exclusif avec activity
  final String travelMode;            // "driving" | ...
  final int travelDurationMinutes;
  final int travelDistanceMeters;
  final String notes;

  TripStepDto({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.estimatedDurationMinutes,
    this.activity,
    this.event,
    required this.travelMode,
    required this.travelDurationMinutes,
    required this.travelDistanceMeters,
    this.notes = '',
  });

  factory TripStepDto.fromJson(Map<String, dynamic> j) {
    return TripStepDto(
      id: j['id'] as int,
      startTime: j['start_time'] as String,
      endTime: j['end_time'] as String?,
      estimatedDurationMinutes: (j['estimated_duration_minutes'] as int?) ?? 0,
      activity: j['activity'] != null
          ? ActivityOrEventDto.fromJson(j['activity'] as Map<String, dynamic>)
          : null,
      event: j['event'] != null
          ? ActivityOrEventDto.fromJson(j['event'] as Map<String, dynamic>)
          : null,
      travelMode: (j['travel_mode'] as String?) ?? 'driving',
      travelDurationMinutes: (j['travel_duration_minutes'] as int?) ?? 0,
      travelDistanceMeters: (j['travel_distance_meters'] as int?) ?? 0,
      notes: (j['notes'] as String?) ?? '',
    );
  }

  TripStep toEntity() {
    final targetDto = activity ?? event;

    final target = StepTarget(
      id: targetDto?.id ?? -1,
      name: targetDto?.name ?? '',
      type: targetDto?.type ?? 'activity',
      placeId: targetDto?.placeId,
      latitude: targetDto?.latitude ?? 0,
      longitude: targetDto?.longitude ?? 0,
      // ⬇️ NEW: remonte les icônes
      primaryIcon: targetDto?.primaryIcon,
      otherIcons: targetDto?.otherIcons ?? const [],
    );

    int _parseH(String s) => int.tryParse(s.split(':')[0]) ?? 0;
    int _parseM(String s) => int.tryParse(s.split(':')[1]) ?? 0;

    final sh = _parseH(startTime);
    final sm = _parseM(startTime);
    final eh = (endTime != null) ? _parseH(endTime!) : null;
    final em = (endTime != null) ? _parseM(endTime!) : null;

    return TripStep(
      id: id,
      startHour: sh,
      startMinute: sm,
      endHour: eh,
      endMinute: em,
      estimatedDurationMinutes: estimatedDurationMinutes,
      target: target,
      travelMode: travelMode,
      travelDurationMinutes: travelDurationMinutes,
      travelDistanceMeters: travelDistanceMeters,
      notes: notes,
    );
  }
}
