//---------------------------------------------------------------------------
// File   : features/planning/presentation/pages/planning_page.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:texas_buddy/features/planning/presentation/overlay/planning_overlay.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.sizeOf(context);
    return SafeArea(
      child: Center(
        child: PlanningOverlay(
          width: size.width,
          height: size.height,
          // En plein écran, on peut désactiver l’animation de toggle
          onToggleTap: () {}, // no-op ou ouvre un modal d’options si tu veux
          stripeColor: AppColors.sand,
          hourTextColor: Colors.white,
          slotHeight: 80.0,
        ),
      ),
    );
  }
}
