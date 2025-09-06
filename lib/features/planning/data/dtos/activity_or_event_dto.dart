//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : feztures/planning/data/dtos/activity_or_event_dto.dart
// Author : Morice
//---------------------------------------------------------------------------

class ActivityOrEventDto {
  final int id;
  final String name;
  final String type;      // "activity" | "event"
  final String? placeId;  // peut être null côté event
  final double latitude;
  final double longitude;

  ActivityOrEventDto({
    required this.id,
    required this.name,
    required this.type,
    this.placeId,
    required this.latitude,
    required this.longitude,
  });

  factory ActivityOrEventDto.fromJson(Map<String, dynamic> j) {
    return ActivityOrEventDto(
      id: j['id'] as int,
      name: j['name'] as String,
      type: (j['type'] as String?) ?? 'activity',
      placeId: j['place_id'] as String?,
      latitude: (j['latitude'] as num).toDouble(),
      longitude: (j['longitude'] as num).toDouble(),
    );
  }
}
