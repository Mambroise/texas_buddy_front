//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/trip_create_wrapper.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter/material.dart';
import 'package:texas_buddy/core/l10n/l10n_ext.dart';
import 'trip_draft.dart';
import 'trip_form_sheet.dart';

class TripCreateWrapper extends StatelessWidget {
  final ValueChanged<TripDraft> onSubmit;
  const TripCreateWrapper({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TripFormSheet(
      initial: null,
      titleText: l10n.tripCreateTitle,
      submitText: l10n.tripCreateCreate,
      onSubmit: onSubmit,
    );
  }
}
