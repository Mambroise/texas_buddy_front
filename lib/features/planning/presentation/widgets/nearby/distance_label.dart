//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/nearby/distance_label.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';

/// Retourne true si on affiche en miles pour la locale donnée.
/// Règle: en / es => miles, sinon km (même logique que use24h).
bool useMilesForLocale(Locale? locale) {
  final code = (locale?.languageCode ?? 'en').toLowerCase();
  return code == 'en' || code == 'es';
}

/// Formatte une distance en km vers texte localisé (km ou mi) avec 1 décimale.
String formatDistanceString({
  required double km,
  required bool useMiles,
  Locale? locale,
}) {
  final langTag = locale?.toLanguageTag() ?? 'en';
  final nf = NumberFormat.decimalPattern(langTag)
    ..minimumFractionDigits = 1
    ..maximumFractionDigits = 1;

  if (useMiles) {
    final miles = km * 0.621371;
    return '${nf.format(miles)} mi';
  } else {
    return '${nf.format(km)} km';
  }
}

/// Label minimaliste (texte seul, rouge Texas). Le positionnement se fait hors du widget.
class DistanceLabel extends StatelessWidget {
  final double km;
  final bool useMiles;

  const DistanceLabel({
    super.key,
    required this.km,
    required this.useMiles,
  });

  @override
  Widget build(BuildContext context) {
    final text = formatDistanceString(
      km: km,
      useMiles: useMiles,
      locale: Localizations.maybeLocaleOf(context),
    );

    return Text(
      text,
      textAlign: TextAlign.right,
      style: const TextStyle(
        color: AppColors.texasRed,
        fontWeight: FontWeight.w800,
        fontSize: 11,
        height: 1.0,
      ),
    );
  }
}
