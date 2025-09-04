//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/hours_list.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';

/// Liste des heures (par défaut 06:00 → 23:00), avec affichage 24h.
/// Utilise TimeOfDay.format(context) et force alwaysUse24HourFormat par défaut.

class HoursList extends StatelessWidget {
  final int firstHour;      // ex: 6
  final int lastHour;       // ex: 23
  final double slotHeight;  // ex: 80.0
  final Color textColor;

  /// true => force affichage 24h "HH:00"
  /// false => affichage 12h "h am/pm" (sans :00)
  final bool use24h;

  const HoursList({
    super.key,
    this.firstHour = 6,
    this.lastHour = 23,
    this.slotHeight = 80,
    this.textColor = Colors.black87,
    this.use24h = true,
  })  : assert(firstHour >= 0 && firstHour <= 23),
        assert(lastHour >= 0 && lastHour <= 23),
        assert(lastHour >= firstHour);

  String _labelForHour(int hour) {
    if (use24h) {
      final hh = hour.toString().padLeft(2, '0');
      return '$hh:00';
    } else {
      final h12 = (hour % 12 == 0) ? 12 : (hour % 12);
      final suffix = hour < 12 ? 'am' : 'pm'; // compact, minuscule
      return '$h12 $suffix';                  // ← sans :00
    }
  }

  @override
  Widget build(BuildContext context) {
    final hours = List<int>.generate((lastHour - firstHour) + 1, (i) => firstHour + i);

    return Column(
      children: [
        for (final h in hours)
          SizedBox(
            height: slotHeight,
            child: Center(
              child: Text(
                _labelForHour(h),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: textColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}