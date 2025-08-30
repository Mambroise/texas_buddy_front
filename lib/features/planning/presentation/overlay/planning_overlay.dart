//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/overlay/planning_overlay.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/features/planning/presentation/cubit/planning_overlay_cubit.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/hours_list.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/fade_in_up.dart';

/// Calque Planning transparent, scrollable, avec swipe L/R pour collapse/expand.
/// N'inclut PAS l'AnimatedPositioned : c'est MapPage qui gère la position.
class PlanningOverlay extends StatefulWidget {
  final double width;
  final double height;
  final VoidCallback onToggleTap;
  final Color stripeColor;      // couleur de la bande droite (timeline visible)
  final Color hourTextColor;    // couleur du texte des heures
  final double slotHeight;      // hauteur d’une tranche horaire

  const PlanningOverlay({
    super.key,
    required this.width,
    required this.height,
    required this.onToggleTap,
    this.stripeColor = Colors.white,
    this.hourTextColor = Colors.blue,
    this.slotHeight = 80.0,
  });

  @override
  State<PlanningOverlay> createState() => _PlanningOverlayState();
}

class _PlanningOverlayState extends State<PlanningOverlay> {
  final _scrollController = ScrollController();
  bool _isUserScrolling = false;

  // Swipe horizontal
  double _dragDx = 0;
  static const _kSwipeDxThreshold = 60.0;
  static const _kSwipeVxThreshold = 400.0;

  void _maybeToggle() {
    if (_isUserScrolling) return;
    widget.onToggleTap();
  }

  @override
  Widget build(BuildContext context) {
    final visibleStripeWidth = widget.width * 0.20; // 20% visible en mode "peek"
    const firstHour = 6;  // 6 AM
    const lastHour  = 23; // 11 PM
    final slotCount = (lastHour - firstHour) + 1;
    final contentHeight = slotCount * widget.slotHeight;
    final mq = MediaQuery.of(context);

    // marge de scroll en bas pour atteindre confortablement la fin
    final extraScrollSpace = (widget.height * 0.65).ceilToDouble();
    final stripeHeight = math.max(widget.height, contentHeight + extraScrollSpace + 4);

    return GestureDetector(
      // ... inchangé ...
      child: NotificationListener<ScrollNotification>(
        // ... inchangé ...
        child: FadeInUp(
          dy: 16,
          duration: const Duration(milliseconds: 240),
          child: ScrollConfiguration(
            behavior: const _NoGlowScroll(),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: widget.height),
                child: Stack(
                  children: [
                    // ... fenêtre + bande timeline inchangées ...
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: visibleStripeWidth,
                        height: stripeHeight,
                        decoration: BoxDecoration(
                          color: widget.stripeColor,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          border: Border.all(color: AppColors.texasBlue, width: 1),
                          boxShadow: const [
                            BoxShadow(blurRadius: 6, offset: Offset(0, 2), color: Color(0x1F000000)),
                            BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: Color(0x14000000)),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: extraScrollSpace),
                          // 🔥 Ici on force le format 24h
                          child: MediaQuery(
                            data: mq.copyWith(alwaysUse24HourFormat: true),
                            child: HoursList(
                              firstHour: firstHour,
                              lastHour: lastHour,
                              slotHeight: widget.slotHeight,
                              textColor: widget.hourTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Supprime l'effet de glow des scrollables
class _NoGlowScroll extends ScrollBehavior {
  const _NoGlowScroll();
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
