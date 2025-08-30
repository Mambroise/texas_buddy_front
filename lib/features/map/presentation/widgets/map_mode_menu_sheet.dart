//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/widgets/map_mode_menu_sheet.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
// L10n
import 'package:texas_buddy/core/l10n/l10n_ext.dart';

class MapModeMenuSheet extends StatelessWidget {
  const MapModeMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final year = DateTime.now().year;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.event_available),
              title: Text(l10n.mapModeEventsTitle),
              subtitle: Text(l10n.mapModeEventsSubtitle(year)),
              onTap: () => Navigator.of(context).pop('events'),
            ),
            const Divider(height: 0),
            ListTile(
              leading: const Icon(Icons.place),
              title: Text(l10n.mapModeNearbyTitle),
              subtitle: Text(l10n.mapModeNearbySubtitle),
              onTap: () => Navigator.of(context).pop('nearby'),
            ),
          ],
        ),
      ),
    );
  }
}

