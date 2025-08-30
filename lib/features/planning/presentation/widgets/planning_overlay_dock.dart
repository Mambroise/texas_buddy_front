//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/planning_overlay_dock.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/features/planning/presentation/cubit/planning_overlay_cubit.dart';
import 'package:texas_buddy/features/planning/presentation/overlay/planning_overlay.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';

class PlanningOverlayDock extends StatelessWidget {
  /// Fractions pour recaser facilement le dock selon l'écran
  final double topFraction;     // ex: 0.20
  final double widthFraction;   // ex: 0.50
  final double heightFactor;    // ex: 1.50
  final Duration duration;
  final Curve curve;

  /// ✅ Couleurs désormais paramétrables (avec defaults doux)
  final Color stripeColor;
  final Color hourTextColor;

  const PlanningOverlayDock({
    super.key,
    this.topFraction = 0.20,
    this.widthFraction = 0.50,
    this.heightFactor = 1.50,
    this.duration = const Duration(milliseconds: 280),
    this.curve = Curves.easeInOutCubic,
    this.stripeColor = AppColors.sand,           // ⬅️ par défaut : sable
    this.hourTextColor = AppColors.texasBlue,    // ⬅️ texte bleu Texas
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final timelineWidth  = size.width  * widthFraction;
    final timelineHeight = size.height * heightFactor;
    final topOffset      = size.height * topFraction;
    final peekLeft       = -(timelineWidth * 0.8);
    const fullLeft       = 0.0;

    return BlocBuilder<PlanningOverlayCubit, PlanningOverlayState>(
      builder: (context, ovr) {
        if (!ovr.visible) return const SizedBox.shrink();
        final targetLeft = ovr.expanded ? fullLeft : peekLeft;

        return AnimatedPositioned(
          duration: duration,
          curve: curve,
          top: topOffset,
          left: targetLeft,
          width: timelineWidth,
          height: timelineHeight,
          child: PlanningOverlay(
            width: timelineWidth,
            height: timelineHeight,
            onToggleTap: context.read<PlanningOverlayCubit>().toggleExpanded,
            // ✅ on RELAY les couleurs au contenu (plus de hard-coded noir/blanc)
            stripeColor: stripeColor,
            hourTextColor: hourTextColor,
            slotHeight: 80.0,
          ),
        );
      },
    );
  }
}
