//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/layers/planning_scrim_layer.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/features/planning/presentation/cubits/planning_overlay_cubit.dart';

/// Couche "voile" au-dessus de la carte quand le PlanningOverlay est visible.
/// - S'assombrit un peu plus en mode expanded (paramétrable)
/// - Laisse passer (ou non) les interactions vers la map via [absorbGestures]
class PlanningScrimLayer extends StatelessWidget {
  const PlanningScrimLayer({
    super.key,
    this.color = Colors.black,
    this.expandedOpacity = 0.72,
    this.collapsedOpacity = 0.22,
    this.duration = const Duration(milliseconds: 180),
    this.curve = Curves.easeOutCubic,
    this.absorbGestures = false, // false = laisse passer les gestes (IgnorePointer)
  });

  final Color color;
  final double expandedOpacity;
  final double collapsedOpacity;
  final Duration duration;
  final Curve curve;

  /// true  = on intercepte les gestes sous la couche (Absorb)
  /// false = on laisse passer (IgnorePointer) → recommandé pour la map
  final bool absorbGestures;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlanningOverlayCubit, PlanningOverlayState>(
      buildWhen: (p, n) => p.visible != n.visible || p.expanded != n.expanded,
      builder: (ctx, ovr) {
        final show = ovr.visible;
        final opacity = ovr.expanded ? expandedOpacity : collapsedOpacity;

        final layer = AnimatedOpacity(
          duration: duration,
          curve: curve,
          opacity: show ? opacity : 0.0,
          child: ColoredBox(color: color),
        );

        // AbsorbPointer intercepte si absorbGestures == true.
        // Sinon IgnorePointer(ignoring: true) laisse passer vers la map.
        return Positioned.fill(
          child: absorbGestures
              ? AbsorbPointer(absorbing: show, child: layer)
              : IgnorePointer(ignoring: true, child: layer),
        );
      },
    );
  }
}
