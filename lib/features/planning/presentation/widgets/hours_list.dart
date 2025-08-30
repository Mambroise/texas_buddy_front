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

  /// Si true, force le format 24h via MediaQuery.copyWith(alwaysUse24HourFormat: true).
  /// Laisse à true pour style FR partout où HoursList est utilisée.
  final bool use24h;

  const HoursList({
    super.key,
    this.firstHour = 6,
    this.lastHour = 23,
    this.slotHeight = 80,
    this.textColor = Colors.black87,
    this.use24h = true,
  }) : assert(firstHour >= 0 && firstHour <= 23),
        assert(lastHour >= 0 && lastHour <= 23),
        assert(lastHour >= firstHour);

  String _labelForHour(BuildContext context, int hour) {
    final t = TimeOfDay(hour: hour % 24, minute: 0);
    return t.format(context); // respectera alwaysUse24HourFormat si renseigné
  }

  @override
  Widget build(BuildContext context) {
    final hours = List<int>.generate((lastHour - firstHour) + 1, (i) => firstHour + i);

    Widget content = Column(
      children: [
        for (final h in hours)
          SizedBox(
            height: slotHeight,
            child: Center(
              child: Text(
                _labelForHour(context, h),
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

    if (!use24h) return content;

    // Forcer le 24h, même si l’OS est en 12h (US).
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(alwaysUse24HourFormat: true),
      child: content,
    );
  }
}
