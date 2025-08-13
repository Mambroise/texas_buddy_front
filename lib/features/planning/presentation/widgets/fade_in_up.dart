//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/fade_in_up.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter/widgets.dart';

/// Petit utilitaire "FadeInUp" sans controller, safe pour le scroll interne.
class FadeInUp extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double dy; // décalage vertical initial (px)

  const FadeInUp({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 240),
    this.curve = Curves.easeOutCubic,
    this.dy = 16,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: curve,
      child: child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * dy),
          child: child,
        ),
      ),
    );
  }
}
