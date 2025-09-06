//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/entities/trip_day.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'trip_step.dart';

class TripDay {
  final int id;
  final DateTime date;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<TripStep> steps; // ⬅️ NEW

  const TripDay({
    required this.id,
    required this.date,
    this.address,
    this.latitude,
    this.longitude,
    this.steps = const [],
  });

  TripDay copyWith({
    int? id,
    DateTime? date,
    String? address,
    double? latitude,
    double? longitude,
    List<TripStep>? steps,
  }) => TripDay(
    id: id ?? this.id,
    date: date ?? this.date,
    address: address ?? this.address,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    steps: steps ?? this.steps,
  );
}