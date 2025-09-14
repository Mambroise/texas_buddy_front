//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/trip_create_wrapper.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:texas_buddy/core/l10n/l10n_ext.dart';
import 'package:texas_buddy/features/planning/domain/entities/trip.dart';
import 'trip_draft.dart';
import 'trip_form_sheet.dart';

class TripEditWrapper extends StatelessWidget {
  final Trip trip;
  final ValueChanged<TripDraft> onSubmit;
  const TripEditWrapper({super.key, required this.trip, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final initial = TripDraft(
      title: trip.title,
      range: DateTimeRange(start: trip.startDate, end: trip.endDate),
      adults: trip.adults,
      children: trip.children,
    );

    return TripFormSheet(
      initial: initial,
      titleText: l10n.tripEditTitle,   // nouvelles clés
      submitText: l10n.tripEditSave,   // nouvelles clés
      onSubmit: onSubmit,
    );
  }
}
