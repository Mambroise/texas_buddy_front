//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/dtos/trip_dto.dart
// Author : Morice
//-------------------------------------------------------------------------


import '../../domain/entities/trip.dart';
import 'trip_day_dto.dart';

class TripDto {
  final int id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final int adults;
  final int children;
  final List<TripDayDto> days;

  TripDto({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.adults,
    required this.children,
    required this.days,
  });

  factory TripDto.fromJson(Map<String, dynamic> j) {
    final daysJson = (j['days'] as List?) ?? const [];
    return TripDto(
      id: j['id'] as int,
      title: j['title'] as String,
      startDate: DateTime.parse(j['start_date'] as String),
      endDate: DateTime.parse(j['end_date'] as String),
      adults: (j['adults'] as int?) ?? 1,
      children: (j['children'] as int?) ?? 0,
      days: daysJson
          .cast<Map<String, dynamic>>()
          .map((d) => TripDayDto.fromJson(d))
          .toList(),
    );
  }

  Trip toEntity() => Trip(
    id: id,
    title: title,
    startDate: startDate,
    endDate: endDate,
    adults: adults,
    children: children,
    days: days.map((d) => d.toEntity()).toList(),
  );
}

extension TripCreateDto on TripCreate {
  Map<String, dynamic> toJson() => {
    'title': title,
    'start_date': startDate.toIso8601String().split('T').first,
    'end_date': endDate.toIso8601String().split('T').first,
    'adults': adults,
    'children': children,
  };
}