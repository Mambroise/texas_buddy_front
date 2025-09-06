//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/timeline/timeline_pane.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/hours_list.dart';
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';

class TripStepVm {
  final TimeOfDay start;
  final int durationMin; // ← NEW: durée en minutes
  final String title;

  const TripStepVm({
    required this.start,
    required this.durationMin,
    required this.title,
  });
}

typedef CreateStepAtTime = Future<void> Function({
required NearbyItem item,
required DateTime day,
required TimeOfDay startTime,
});

class TimelinePane extends StatefulWidget {
  const TimelinePane({
    super.key,
    required this.height,
    required this.firstHour,
    required this.lastHour,
    required this.slotHeight,
    required this.use24h,
    required this.stripeColor,
    required this.hourTextColor,
    required this.expanded,
    required this.onToggleTap,
    required this.onRequestExpanded,
    this.stripeFraction = 0.20,

    // nouveaux
    this.steps = const <TripStepVm>[],
    this.hasAddress = true,
    this.onAddAddress,
    this.selectedDay,
    this.onCreateStep,
  });

  final double height;
  final int firstHour;
  final int lastHour;
  final double slotHeight;
  final bool use24h;
  final Color stripeColor;
  final Color hourTextColor;
  final bool expanded;
  final VoidCallback onToggleTap;
  final ValueChanged<bool> onRequestExpanded;
  final double stripeFraction;

  // nouveaux
  final List<TripStepVm> steps;
  final bool hasAddress;
  final VoidCallback? onAddAddress;
  final DateTime? selectedDay;
  final CreateStepAtTime? onCreateStep;

  @override
  State<TimelinePane> createState() => _TimelinePaneState();
}

class _TimelinePaneState extends State<TimelinePane> {
  final _scrollController = ScrollController();
  final _dropKey = GlobalKey();
  bool _isUserScrolling = false;

  double get _gridTopInset => widget.slotHeight * 0.5;

  // Swipe horizontal
  double _dragDx = 0;
  static const _kSwipeDxThreshold = 60.0;
  static const _kSwipeVxThreshold = 400.0;

  // État hover DnD
  double? _hoverY;
  NearbyItem? _hoverItem;

  // ---- Helpers temps <-> pixels ------------------------------------------

  double _contentHeight() {
    final slotCount = (widget.lastHour - widget.firstHour) + 1;
    return slotCount * widget.slotHeight;
  }

  double _snapY(double yModel) {
    // on snap dans l’espace "modèle" (sans inset)
    final contentH = _contentHeight();
    final clamped = yModel.clamp(0.0, math.max(0.0, contentH - 1.0));
    final slot = (clamped / widget.slotHeight).roundToDouble();
    return slot * widget.slotHeight;
  }

  TimeOfDay _yToTime(double yUi) {
    // ramène la coordonnée UI à la "coordonnée modèle" (0 = début d’heure)
    final y = yUi - _gridTopInset;
    final totalSlots = (y / widget.slotHeight);
    final hour = widget.firstHour + totalSlots.floor();
    final minutes = (((totalSlots - totalSlots.floor()) * 60) / 5).round() * 5; // snap 5'
    return TimeOfDay(
      hour: hour.clamp(0, 23),
      minute: minutes.clamp(0, 55),
    );
  }

  double _timeToY(TimeOfDay t) {
    final h = (t.hour - widget.firstHour).toDouble();
    // + inset pour aligner sur la ligne "centrée" d'HoursList
    return (h * widget.slotHeight) + (t.minute / 60.0) * widget.slotHeight + _gridTopInset;
  }

  double _durationToHeight(int minutes) {
    final h = (minutes / 60.0) * widget.slotHeight;
    // hauteur mini pour rester saisissable visuellement
    return h.clamp(28.0, widget.slotHeight * 4); // min 28px, max 4h (ajuste si besoin)
  }

  double _localY(Offset globalOffset) {
    final rb = _dropKey.currentContext!.findRenderObject() as RenderBox;
    final local = rb.globalToLocal(globalOffset);
    return local.dy + _scrollController.offset;
  }

  void _updateHover(DragTargetDetails<NearbyItem> d) {
    setState(() {
      _hoverY = _localY(d.offset);
      _hoverItem = d.data;
    });
  }

  // ------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, cons) {
        final leftPaneW = cons.maxWidth;
        final stripeW = leftPaneW * widget.stripeFraction;
        final dropW = leftPaneW - stripeW;

        final contentH = _contentHeight();
        final extraScroll = widget.height * 0.50;
        final stripeH = contentH + extraScroll + 4.0;

        final double slideFrac = -(1.0 - (stripeW / leftPaneW));

        void _onHStart(_) => _dragDx = 0;
        void _onHUpdate(DragUpdateDetails d) => _dragDx += d.delta.dx;
        void _onHEnd(DragEndDetails d) {
          if (_isUserScrolling) return;
          final vx = d.primaryVelocity ?? 0;
          if (vx > _kSwipeVxThreshold || _dragDx > _kSwipeDxThreshold) {
            if (!widget.expanded) widget.onRequestExpanded(true);
          } else if (vx < -_kSwipeVxThreshold || _dragDx < -_kSwipeDxThreshold) {
            if (widget.expanded) widget.onRequestExpanded(false);
          }
          _dragDx = 0;
        }

        return SizedBox(
          width: leftPaneW,
          height: widget.height,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            offset: Offset(widget.expanded ? 0.0 : slideFrac, 0.0),
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n is ScrollStartNotification) _isUserScrolling = true;
                if (n is ScrollEndNotification) _isUserScrolling = false;
                return false;
              },
              child: ScrollConfiguration(
                behavior: const _NoGlowScroll(),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    height: stripeH,
                    child: Stack(
                      children: [
                        // 1) Zone de drop (gauche)
                        Align(
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            key: _dropKey,
                            width: dropW,
                            height: stripeH,
                            child: IgnorePointer(
                              ignoring: !widget.expanded,
                              child: DragTarget<NearbyItem>(
                                onWillAcceptWithDetails: (d) {
                                  _updateHover(d);
                                  return widget.onCreateStep != null && widget.selectedDay != null;
                                },
                                onMove: _updateHover,
                                onLeave: (_) => setState(() {
                                  _hoverY = null;
                                  _hoverItem = null;
                                }),
                                onAcceptWithDetails: (d) async {
                                  if (widget.onCreateStep == null || widget.selectedDay == null) return;
                                  final y = _localY(d.offset);
                                  final snapped = _snapY(y);
                                  final t = _yToTime(snapped);
                                  final item = d.data;
                                  setState(() {
                                    _hoverY = null;
                                    _hoverItem = null;
                                  });
                                  await widget.onCreateStep!(
                                    item: item,
                                    day: widget.selectedDay!,
                                    startTime: t,
                                  );
                                },
                                builder: (_, __, ___) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteGlow,
                                      border: Border(
                                        top: BorderSide(color: AppColors.texasBlue, width: 1),
                                      ),
                                    ),
                                    padding: EdgeInsets.only(bottom: extraScroll),
                                    alignment: Alignment.topLeft,
                                    child: Stack(
                                      children: [
                                        // Steps existants (position + hauteur par durée)
                                        ...widget.steps.map((s) {
                                          final top = _timeToY(s.start);
                                          final height = _durationToHeight(s.durationMin);
                                          return Positioned(
                                            top: top,
                                            left: 8,
                                            right: 8,
                                            height: height,
                                            child: _StepCard(title: s.title),
                                          );
                                        }),

                                        // Placeholder vertical si pas d'adresse et pas de steps
                                        if (!widget.hasAddress && widget.steps.isEmpty)
                                          Positioned.fill(
                                            child: GestureDetector(
                                              onTap: widget.onAddAddress,
                                              child: const Align(
                                                alignment: Alignment.centerLeft,
                                                child: _VerticalPrompt(),
                                              ),
                                            ),
                                          ),

                                        // Guide de drop (ligne + ghost sur 60')
                                        if (_hoverY != null)
                                          Positioned(
                                            top: _snapY(_hoverY!),
                                            left: 0,
                                            right: 0,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Container(
                                                  height: 2,
                                                  color: AppColors.texasBlue.withValues(alpha: .55),
                                                ),
                                                const SizedBox(height: 4),
                                                if (_hoverItem != null)
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    child: Opacity(
                                                      opacity: .85,
                                                      child: SizedBox(
                                                        height: _durationToHeight(60), // ghost 1h
                                                        child: _StepCard(title: _hoverItem!.name),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        // 2) Stripe heures (droite)
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (!_isUserScrolling) widget.onToggleTap();
                            },
                            onHorizontalDragStart: _onHStart,
                            onHorizontalDragUpdate: _onHUpdate,
                            onHorizontalDragEnd: _onHEnd,
                            child: Container(
                              width: stripeW,
                              height: stripeH,
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
                                  firstHour: widget.firstHour,
                                  lastHour: widget.lastHour,
                                  slotHeight: widget.slotHeight,
                                  textColor: widget.hourTextColor,
                                  use24h: widget.use24h,
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
      },
    );
  }
}

class _StepCard extends StatelessWidget {
  final String title;
  const _StepCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.texasBlue, width: 1),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(blurRadius: 8, offset: Offset(0, 4), color: Color(0x14000000))
        ],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.texasBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _VerticalPrompt extends StatelessWidget {
  const _VerticalPrompt();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: RotatedBox(
        quarterTurns: 3, // -90°
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add_location_alt, size: 16, color: AppColors.texasBlue),
            SizedBox(width: 6),
            Text(
              "ajouter l'adresse de l'hotel",
              style: TextStyle(
                color: AppColors.texasBlue,
                fontWeight: FontWeight.w800,
                letterSpacing: .5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoGlowScroll extends ScrollBehavior {
  const _NoGlowScroll();
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}
