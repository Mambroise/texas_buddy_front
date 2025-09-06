//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/dtos/trip_day_dto.dart
// Author : Morice
//-------------------------------------------------------------------------


import '../../domain/entities/trip_day.dart';
import 'trip_step_dto.dart';

class TripDayDto {
  final int id;
  final DateTime date;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<TripStepDto> steps; // ⬅️ NEW

  TripDayDto({
    required this.id,
    required this.date,
    this.address,
    this.latitude,
    this.longitude,
    this.steps = const [],
  });

  factory TripDayDto.fromJson(Map<String, dynamic> j) {
    return TripDayDto(
      id: j['id'] as int,
      date: DateTime.parse(j['date'] as String),
      address: j['address'] as String?,
      latitude: (j['latitude'] as num?)?.toDouble(),
      longitude: (j['longitude'] as num?)?.toDouble(),
      steps: ((j['steps'] as List?) ?? const [])
          .cast<Map<String, dynamic>>()
          .map((s) => TripStepDto.fromJson(s))
          .toList(),
    );
  }

  TripDay toEntity() => TripDay(
    id: id,
    date: date,
    address: address,
    latitude: latitude,
    longitude: longitude,
    steps: steps.map((e) => e.toEntity()).toList(),
  );
}