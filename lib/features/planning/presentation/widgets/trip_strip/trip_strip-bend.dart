


import 'package:flutter/material.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';


/// Bandeau full-width avec fond blanc 90% et double bordure
class TripStripBand extends StatelessWidget {
  final double height;
  final Widget child;
  final EdgeInsetsGeometry margin; // ⬅️ nouveau

  const TripStripBand({
    super.key,
    required this.height,
    required this.child,
    this.margin = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    // withValues nécessite Flutter 3.22+
    final Color bg = Colors.white.withValues(alpha: 0.90);

    return Container(
      margin: margin, // ⬅️ applique la marge externe
      width: double.infinity,
      height: height,
      child: Stack(
        children: [
          // Fond + bordures extérieures épaisses (4px)
          Container(
            width: double.infinity,
            height: height,
            foregroundDecoration: BoxDecoration(
              color: bg, // alpha 0.90
              border: const Border(
                top: BorderSide(color: AppColors.texasBlue, width: 2),
                bottom: BorderSide(color: AppColors.texasBlue, width: 4),
              ),
            ),
          ),

          // Bordures intérieures fines (1px), décalées vers l'intérieur
          const Positioned(
            top: 4, left: 0, right: 0,
            child: SizedBox(
              height: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(color: AppColors.texasBlue),
              ),
            ),
          ),
          const Positioned(
            bottom: 6, left: 0, right: 0,
            child: SizedBox(
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: AppColors.texasBlue),
              ),
            ),
          ),

          // Contenu centré
          Center(child: child),
        ],
      ),
    );
  }
}
