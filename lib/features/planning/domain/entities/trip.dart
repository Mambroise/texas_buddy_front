//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/entities/trip.dart
// Author : Morice
//---------------------------------------------------------------------------



import 'trip_day.dart';

class Trip {
  final int id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final int adults;
  final int children;
  final List<TripDay> days; // ⬅️ NEW (vide si pas renvoyé)

  const Trip({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.adults,
    required this.children,
    this.days = const [],
  });

  Trip copyWith({
    int? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    int? adults,
    int? children,
    List<TripDay>? days,
  }) => Trip(
    id: id ?? this.id,
    title: title ?? this.title,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    adults: adults ?? this.adults,
    children: children ?? this.children,
    days: days ?? this.days,
  );
}


class TripCreate {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final int adults;
  final int children;
  final List<TripDay> days;

  const TripCreate({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.adults,
    required this.children,
    this.days = const [],
  });
}
