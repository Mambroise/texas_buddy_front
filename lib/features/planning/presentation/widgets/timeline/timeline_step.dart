//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/timeline/timeline_step.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';


/// ViewModel d’un step affiché dans la timeline.
class TripStepVm {
  final int? id;
  final TimeOfDay start;
  final int durationMin;
  final String title;

  final double? latitude;
  final double? longitude;

  /// durée de trajet DEPUIS le step précédent (si connue)
  final int? travelDurationMinutes;

  /// Icônes déjà résolues
  final IconData? primaryIcon;
  final List<IconData> otherIcons;

  const TripStepVm({
    this.id,
    required this.start,
    required this.durationMin,
    required this.title,
    this.latitude,
    this.longitude,
    this.travelDurationMinutes,
    this.primaryIcon,
    this.otherIcons = const <IconData>[],
  });
}

/// Signature pour créer un step à l’instant déposé sur la timeline.
typedef CreateStepAtTime = Future<void> Function({
required NearbyItem item,
required int tripDayId,
required DateTime day,
required TimeOfDay startTime,
int? travelDurationMinutes,
int? travelDistanceMeters,
});

/// Helpers
bool hasValidCoords(double? lat, double? lng) =>
    lat != null && lng != null && lat.abs() > 0.0001 && lng.abs() > 0.0001;

/// Petit sugar via extension
extension TripStepVmX on TripStepVm {
  bool get hasCoords => hasValidCoords(latitude, longitude);
}

/// Carte visuelle d’un step (ex-`_StepCard`, rendue publique).
class StepCard extends StatelessWidget {
  final String title;
  final IconData? primaryIcon;
  final List<IconData> otherIcons;
  final int? durationMin;
  final double? latitude;
  final double? longitude;
  final bool selected;
  final Color? bgColor;
  final Color? borderColor;

  const StepCard({
    super.key,
    required this.title,
    this.primaryIcon,
    this.otherIcons = const [],
    this.durationMin,
    this.latitude,
    this.longitude,
    this.selected = false,
    this.bgColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolvedBg = bgColor ??
        (selected ? const Color(0xFFFFF3F3) : Colors.white);
    final Color resolvedBorder = borderColor ??
        (selected ? AppColors.texasRedGlow : AppColors.texasBlue);

    return Container(
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: resolvedBg,                 // <-- utilise la couleur override
        border: Border(
          top: BorderSide(
            color: resolvedBorder,
            width: selected ? 2 : 1,
          ),
          bottom: BorderSide(
            color: resolvedBorder,
            width: selected ? 2 : 1,
          ),
        ),
        boxShadow: const [
          BoxShadow(blurRadius: 12, offset: Offset(0, 6), color: Color(0x24000000)),
          BoxShadow(blurRadius: 24, offset: Offset(0, 12), color: Color(0x14000000)),
        ],
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Titre
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 6),

            // Icônes
            if (primaryIcon != null || otherIcons.isNotEmpty)
              Wrap(
                spacing: 10,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  if (primaryIcon != null)
                    Icon(primaryIcon, size: 10, color: AppColors.texasRedGlow),
                  ...otherIcons.map((ic) => Icon(ic, size: 10, color: AppColors.black)),
                ],
              ),

            // Durée
            if (durationMin != null) ...[
              const SizedBox(height: 6),
              Text('$durationMin min', style: TextStyle(fontSize: 10, color: AppColors.black)),
            ],

            // Lat/Lng (petit, discret)
            if (latitude != null && longitude != null) ...[
              const SizedBox(height: 4),
              Text(
                '(${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)})',
                style: const TextStyle(fontSize: 9, color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
