//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/dtos/trip_dto.dart
// Author : Morice
//-------------------------------------------------------------------------


import '../../domain/entities/trip.dart';

class TripDto {
  final int id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final int adults;
  final int children;

  TripDto({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.adults,
    required this.children,
  });

  factory TripDto.fromJson(Map<String, dynamic> j) {
    return TripDto(
      id: j['id'] as int,
      title: j['title'] as String,
      startDate: DateTime.parse(j['start_date'] as String),
      endDate: DateTime.parse(j['end_date'] as String),
      adults: j['adults'] as int? ?? 0,
      children: j['children'] as int? ?? 0,
    );
  }

  Trip toEntity() => Trip(
    id: id,
    title: title,
    startDate: startDate,
    endDate: endDate,
    adults: adults,
    children: children,
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
