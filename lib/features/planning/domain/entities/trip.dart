//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/entities/trip.dart
// Author : Morice
//---------------------------------------------------------------------------


class Trip {
  final int id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final int adults;
  final int children;

  const Trip({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.adults,
    required this.children,
  });
}

class TripCreate {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final int adults;
  final int children;

  const TripCreate({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.adults,
    required this.children,
  });
}
