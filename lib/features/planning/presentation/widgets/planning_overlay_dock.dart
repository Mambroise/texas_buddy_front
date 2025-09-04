//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/planning_overlay_dock.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/features/planning/presentation/cubits/planning_overlay_cubit.dart';
import 'package:texas_buddy/features/planning/presentation/overlay/planning_overlay.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';

// features/planning/presentation/widgets/planning_overlay_dock.dart
class PlanningOverlayDock extends StatelessWidget {
  final double topPadding; // sous la chip bar
  final Duration duration;
  final Curve curve;
  final Color stripeColor;
  final Color hourTextColor;

  const PlanningOverlayDock({
    super.key,
    this.topPadding = 92.0,
    this.duration = const Duration(milliseconds: 240),
    this.curve = Curves.easeOutCubic,
    this.stripeColor = AppColors.sand,
    this.hourTextColor = AppColors.texasBlue,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // ⬇️ Remonte de 1/5 d’écran
// ⬆️ Remonte de 2/5 d’écran (0.40)
    const double kLiftFraction = 0.40;
    final double lift = size.height * kLiftFraction;

    final double effectiveTop = (topPadding - lift) < 0.0 ? 0.0 : (topPadding - lift);
    final double panelWidth  = size.width;
    final double panelHeight = size.height - effectiveTop;

    return BlocBuilder<PlanningOverlayCubit, PlanningOverlayState>(
      buildWhen: (p, n) => p.visible != n.visible,
      builder: (context, ovr) {
        return Positioned(
          top: effectiveTop,
          left: 0,
          right: 0,
          height: panelHeight,
          child: AnimatedSwitcher(
            duration: duration,
            switchInCurve: curve,
            switchOutCurve: curve,
            transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
            child: ovr.visible
                ? PlanningOverlay(
              key: const ValueKey('planning-overlay'),
              width: panelWidth,
              height: panelHeight,
              onToggleTap: context.read<PlanningOverlayCubit>().toggleExpanded,
              stripeColor: stripeColor,
              hourTextColor: hourTextColor,
              slotHeight: 80.0,
            )
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
