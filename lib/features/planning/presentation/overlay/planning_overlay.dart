//---------------------------------------------------------------------------
// File   : features/planning/presentation/overlay/planning_overlay.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/features/planning/presentation/cubits/planning_overlay_cubit.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/hours_list.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/fade_in_up.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/trips_strip.dart';

class PlanningOverlay extends StatefulWidget {
  final double width;
  final double height;
  final VoidCallback onToggleTap;
  final Color stripeColor;
  final Color hourTextColor;
  final double slotHeight;

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

// features/planning/presentation/overlay/planning_overlay.dart (extrait build)
  @override
  Widget build(BuildContext context) {
    const double headerGap = 0.0;
    final double topHeight    = widget.height / 4.0;                   // 1/3
    final double bottomHeight = widget.height - topHeight - headerGap; // 2/3
    final double leftPaneW    = widget.width / 2.0;
    final double rightPaneW   = widget.width - leftPaneW;

    // Timeline interne : 20% pour la bande d’heures
    final double stripeW = leftPaneW * 0.20;
    final double dropW   = leftPaneW - stripeW;

    const int firstHour = 6;
    const int lastHour  = 23;
    final int slotCount = (lastHour - firstHour) + 1;

    final String lang = Localizations.localeOf(context).languageCode.toLowerCase();
    final bool use24h = !(lang == 'en' || lang == 'es');

    final double contentH     = slotCount * widget.slotHeight;
    final double extraScroll  = bottomHeight * 0.50;
    final double stripeHeight = contentH + extraScroll + 4.0;

    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n is ScrollStartNotification) _isUserScrolling = true;
        if (n is ScrollEndNotification)   _isUserScrolling = false;
        return false;
      },
      child:  Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── HEADER FIXE (1/3) ─────────────────────────────────────────
            SizedBox(
              height: topHeight,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: widget.width * 0.92),
                  child: TripsStrip(
                    height: topHeight,
                    trips: const <String>[], // TODO: brancher BDD
                    onNewTrip: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Créer un nouveau voyage (TODO)')),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: headerGap),

            // ── BAS (2/3) : Row (gauche = timeline, droite = liste) ──────
            SizedBox(
              height: bottomHeight,
              child: Row(
                children: [
// ==== COLONNE GAUCHE (SLIDE SEULEMENT ICI) ====
                  BlocBuilder<PlanningOverlayCubit, PlanningOverlayState>(
                    buildWhen: (p, n) => p.expanded != n.expanded,
                    builder: (context, ovr) {
                      final double slideFrac = -(1.0 - (stripeW / leftPaneW)); // ne laisse visible que la stripe en collapsed

                      // Helpers swipe H
                      void _onHStart(_) { _dragDx = 0; }
                      void _onHUpdate(DragUpdateDetails d) { _dragDx += d.delta.dx; }
                      void _onHEnd(DragEndDetails d) {
                        if (_isUserScrolling) return;
                        final vx = d.primaryVelocity ?? 0;
                        final cubit = context.read<PlanningOverlayCubit>();
                        final expanded = cubit.state.expanded;
                        if (vx > _kSwipeVxThreshold || _dragDx > _kSwipeDxThreshold) {
                          if (!expanded) cubit.expand();     // → droite
                        } else if (vx < -_kSwipeVxThreshold || _dragDx < -_kSwipeDxThreshold) {
                          if (expanded) cubit.collapse();    // ← gauche
                        }
                        _dragDx = 0;
                      }

                      return SizedBox(
                        width: leftPaneW,
                        height: bottomHeight,
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          offset: Offset(ovr.expanded ? 0.0 : slideFrac, 0.0),

                          child: ScrollConfiguration(
                            behavior: const _NoGlowScroll(),
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              physics: const BouncingScrollPhysics(),
                              child: SizedBox(
                                height: stripeHeight,
                                child: Stack(
                                  children: [
                                    // 1) ZONE DE DROP (GAUCHE)
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: SizedBox(
                                        width: dropW,
                                        height: stripeHeight,

                                        // Quand collapsed → laisse passer vers la map
                                        child: IgnorePointer(
                                          ignoring: !ovr.expanded,

                                          // ⚠️ plus de onTap ici (tap toggle supprimé)
                                          // On garde le swipe H uniquement quand expanded
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onHorizontalDragStart: _onHStart,
                                            onHorizontalDragUpdate: _onHUpdate,
                                            onHorizontalDragEnd: _onHEnd,
                                            child: Container(
                                              decoration:BoxDecoration(
                                                color: AppColors.whiteGlow,
                                                border: Border(
                                                  top: BorderSide(color: AppColors.texasBlue, width: 1),
                                                ),
                                              ),
                                              padding: EdgeInsets.only(bottom: extraScroll),
                                              alignment: Alignment.topLeft,
                                              // TODO: DragTarget<NearbyItem>
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // 2) STRIPE HEURES (DROITE de la colonne gauche)
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        // ✅ tap toggle RÉSERVÉ à la stripe
                                        onTap: () {
                                          if (!_isUserScrolling) widget.onToggleTap();
                                        },
                                        // Swipe H actif en permanence sur la stripe
                                        onHorizontalDragStart: _onHStart,
                                        onHorizontalDragUpdate: _onHUpdate,
                                        onHorizontalDragEnd: _onHEnd,
                                        child: Container(
                                          width: stripeW,
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
                                            padding: EdgeInsets.only(bottom: extraScroll),
                                            child: HoursList(
                                              firstHour: firstHour,
                                              lastHour: lastHour,
                                              slotHeight: widget.slotHeight,
                                              textColor: widget.hourTextColor,
                                              use24h: use24h,
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
                      );
                    },
                  ),


                  // ==== COLONNE DROITE (FIXE) ====
                  SizedBox(
                    width: rightPaneW,
                    height: bottomHeight,
                    child: ScrollConfiguration(
                      behavior: const _NoGlowScroll(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        physics: const BouncingScrollPhysics(),
                        itemCount: 8, // TODO: data réelle
                        itemBuilder: (ctx, i) => Container(
                          margin: const EdgeInsets.only(top: 12),
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.texasBlue, width: 1),
                            boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x12000000))],
                          ),
                          child: Center(
                            child: Text('Card #$i (TODO)', style: const TextStyle(color: AppColors.texasBlue)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }


}

class _NoGlowScroll extends ScrollBehavior {
  const _NoGlowScroll();
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
