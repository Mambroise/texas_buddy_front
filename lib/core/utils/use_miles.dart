//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : core/utils/use_miles.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// true = miles pour en/es, sinon km
bool useMilesForLocale(Locale? locale) {
  final code = (locale?.languageCode ?? 'en').toLowerCase();
  return code == 'en' || code == 'es';
}

/// ✅ formate une distance à partir de METERS (backend travel)
String formatDistanceFromMeters({
  required int meters,
  required bool useMiles,
  Locale? locale,
}) {
  final langTag = locale?.toLanguageTag() ?? 'en';
  final nf = NumberFormat.decimalPattern(langTag)
    ..minimumFractionDigits = 1
    ..maximumFractionDigits = 1;

  if (useMiles) {
    final miles = meters / 1609.344;
    return '${nf.format(miles)} mi';
  } else {
    final km = meters / 1000.0;
    return '${nf.format(km)} km';
  }
}

/// ✅ minutes -> "63 min" (simple, lisible)
String formatMinutes(int minutes) => '$minutes min';
