//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/trip_draft.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter/material.dart';

class TripDraft {
  final String title;
  final DateTimeRange range;
  final int adults;
  final int children;

  const TripDraft({
    required this.title,
    required this.range,
    required this.adults,
    required this.children,
  });
}
