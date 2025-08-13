//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/hours_list.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter/material.dart';

/// Liste des heures (6 AM → 11 PM par défaut)
class HoursList extends StatelessWidget {
  final int firstHour;     // ex: 6
  final int lastHour;      // ex: 23
  final double slotHeight; // ex: 80.0
  final Color textColor;

  const HoursList({
    super.key,
    this.firstHour = 6,
    this.lastHour = 23,
    this.slotHeight = 80,
    this.textColor = Colors.black87,
  });

  String _fmt(int h) {
    final period = h < 12 ? 'AM' : 'PM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12 $period';
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
                _fmt(h),
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
