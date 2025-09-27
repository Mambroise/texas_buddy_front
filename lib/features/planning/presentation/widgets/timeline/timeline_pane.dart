//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/timeline/timeline_pane.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/core/l10n/l10n_ext.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/hours_list.dart';
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';
import 'package:texas_buddy/features/map/presentation/cubits/map_focus_cubit.dart';

// ⬇️ fichier extrait
import 'package:texas_buddy/features/planning/presentation/widgets/timeline/timeline_step.dart';

class TimelinePane extends StatefulWidget {
  final int? selectedTripDayId;

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
    this.selectedTripDayId,
    this.tripDayLatitude,
    this.tripDayLongitude,
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
  final double? tripDayLatitude;   // ➕
  final double? tripDayLongitude;

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

  // ✅ durée proposée pour l’item en hover (60’ par défaut)
  int _hoverDurationMin = 60;
  // ✅ le créneau est-il libre ?
  bool _canDropHere = true;

  int? _selectedStepId;
  String? _selectedTitleFallback;
  TimeOfDay? _selectedStartFallback;

  // pour auto-select après création
  String? _pendingTitle;
  TimeOfDay? _pendingStart;

  // AutoScroll
  Timer? _autoScrollTimer;
  static const double _kAutoScrollEdge = 80.0;
  static const double _kAutoScrollMaxSpeed = 900.0;

  // ---- Helpers temps <-> pixels ------------------------------------------

  void _focusTripDayIfPossible() {
    if (widget.hasAddress &&
        widget.tripDayLatitude != null &&
        widget.tripDayLongitude != null) {
      context.read<MapFocusCubit>().focusTripDay(
        widget.tripDayLatitude!, widget.tripDayLongitude!, zoom: 14,
      );
    }
  }

  double _contentHeight() {
    final slotCount = (widget.lastHour - widget.firstHour) + 1;
    return slotCount * widget.slotHeight;
  }

  double _snapY15(double yModel) {
    final contentH = _contentHeight();
    final clamped = yModel.clamp(0.0, math.max(0.0, contentH - 1.0));
    final quarterH = widget.slotHeight / 4.0; // 15'
    final quarter = (clamped / quarterH).roundToDouble();
    return quarter * quarterH;
  }

  TimeOfDay _yToTime(double yUi) {
    final y = yUi - _gridTopInset;
    final totalHours = y / widget.slotHeight;
    final hour = widget.firstHour + totalHours.floor();
    final minutes = (((totalHours - totalHours.floor()) * 60) / 15).round() * 15; // 15'
    return TimeOfDay(
      hour: hour.clamp(0, 23),
      minute: minutes.clamp(0, 45),
    );
  }

  double _timeToY(TimeOfDay t) {
    final h = (t.hour - widget.firstHour).toDouble();
    return (h * widget.slotHeight) + (t.minute / 60.0) * widget.slotHeight + _gridTopInset;
  }

  double _durationToHeight(int minutes) {
    final h = (minutes / 60.0) * widget.slotHeight;
    return h.clamp(28.0, widget.slotHeight * 4);
  }

  double _localY(Offset globalOffset) {
    final rb = _dropKey.currentContext!.findRenderObject() as RenderBox;
    final local = rb.globalToLocal(globalOffset);
    return local.dy + _scrollController.offset;
  }

  // ✅ Nearby → durée proposée (même logique que côté overlay)
  int _proposedDurationFor(NearbyItem it) {
    if (it.startDateTime != null && it.endDateTime != null) {
      final d = it.endDateTime!.difference(it.startDateTime!).inMinutes;
      if (d.isFinite) {
        final clamped = d.clamp(15, 240);
        return clamped;
      }
    }
    return 60;
  }

  // ✅ utilitaires minutes depuis minuit
  int _toMin(TimeOfDay t) => t.hour * 60 + t.minute;

  // ✅ check overlap avec steps existants (fenêtre bloquée actuelle = [start ; start+dur])
  bool _hasOverlap(TimeOfDay start, int durationMin) {
    final newStart = _toMin(start);
    final newEnd   = newStart + durationMin;
    for (final s in widget.steps) {
      final sStart = _toMin(s.start);
      final sEnd   = sStart + s.durationMin;
      // [a,b) intersect [c,d) => a<d && c<b
      if (newStart < sEnd && sStart < newEnd) return true;
    }
    return false;
  }

  // ✅ met à jour hover + calcul disponibilité
  void _updateHover(DragTargetDetails<NearbyItem> d) {
    final y = _localY(d.offset);
    final snappedY = _snapY15(y);

    final item = d.data;
    final dur  = _proposedDurationFor(item);       // ← durée réelle (60' par défaut, sinon event)
    final t    = _yToTime(snappedY);

    setState(() {
      _hoverY = y;
      _hoverItem = item;
      _hoverDurationMin = dur;                      // ← la hauteur du ghost dépend de ça
      _canDropHere = !_hasOverlap(t, dur);         // ← calcule l’overlap
    });
  }

  bool _isSelected(TripStepVm s) {
    if (_selectedStepId != null && s.id != null) return s.id == _selectedStepId;
    return _selectedTitleFallback == s.title &&
        _selectedStartFallback?.hour == s.start.hour &&
        _selectedStartFallback?.minute == s.start.minute;
  }

  void _selectStep(TripStepVm s) {
    setState(() {
      _selectedStepId = s.id;
      _selectedTitleFallback = s.title;
      _selectedStartFallback = s.start;
    });

    if (s.hasCoords) {
      context.read<MapFocusCubit>().focusTripStep(s.latitude!, s.longitude!, zoom: 16);
    } else {
      _focusTripDayIfPossible();
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedStepId = null;
      _selectedTitleFallback = null;
      _selectedStartFallback = null;
    });
    _focusTripDayIfPossible();
  }

  void _toggleStepSelection(TripStepVm s) {
    if (_isSelected(s)) {
      _clearSelection();
    } else {
      _selectStep(s);
    }
  }

  @override
  void didUpdateWidget(covariant TimelinePane old) {
    super.didUpdateWidget(old);
    if (old.selectedTripDayId != widget.selectedTripDayId) {
      _clearSelection();
    }
    if (_pendingTitle != null && _pendingStart != null) {
      final idx = widget.steps.indexWhere((s) =>
      s.title == _pendingTitle &&
          s.start.hour == _pendingStart!.hour &&
          s.start.minute == _pendingStart!.minute);
      if (idx != -1) {
        final created = widget.steps[idx];
        _selectStep(created);
        _pendingTitle = null;
        _pendingStart = null;
      }
    }
  }

  // AutoScroll when dragging
  void _startAutoScroll() {
    _autoScrollTimer ??= Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_hoverY == null || !_scrollController.hasClients) return;
      final viewportY = _hoverY! - _scrollController.offset;
      final viewportH = widget.height;

      double dyPerSec = 0.0;
      if (viewportY < _kAutoScrollEdge) {
        final t = (_kAutoScrollEdge - viewportY).clamp(0, _kAutoScrollEdge) / _kAutoScrollEdge;
        dyPerSec = -_kAutoScrollMaxSpeed * t;
      } else if (viewportH - viewportY < _kAutoScrollEdge) {
        final t = (_kAutoScrollEdge - (viewportH - viewportY)).clamp(0, _kAutoScrollEdge) / _kAutoScrollEdge;
        dyPerSec = _kAutoScrollMaxSpeed * t;
      }

      if (dyPerSec == 0.0) {
        _stopAutoScroll();
        return;
      }

      final dy = dyPerSec * (16 / 1000);
      final pos = _scrollController.position;
      final target = (pos.pixels + dy).clamp(0.0, pos.maxScrollExtent);
      _scrollController.jumpTo(target);
      setState(() {});
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _updateAutoScroll() {
    if (_hoverY == null || !_scrollController.hasClients) {
      _stopAutoScroll();
      return;
    }
    final viewportY = _hoverY! - _scrollController.offset;
    final viewportH = widget.height;
    final nearTop = viewportY < _kAutoScrollEdge;
    final nearBottom = (viewportH - viewportY) < _kAutoScrollEdge;
    if (nearTop || nearBottom) {
      _startAutoScroll();
    } else {
      _stopAutoScroll();
    }
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
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: stripeH),
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
                                    _updateAutoScroll();
                                    // ✅ bloque l’accept si overlap détecté
                                    return widget.onCreateStep != null &&
                                        widget.selectedDay != null &&
                                        _canDropHere;
                                  },
                                  onMove: (d) {
                                    _updateHover(d);
                                    _updateAutoScroll();
                                  },
                                  onLeave: (_) => setState(() {
                                    _hoverY = null;
                                    _hoverItem = null;
                                    _canDropHere = true;
                                    _stopAutoScroll();
                                  }),
                                  onAcceptWithDetails: (d) async {
                                    if (widget.onCreateStep == null || widget.selectedDay == null) return;

                                    // 🧠 recalcul fiable du temps visé (en tenant compte du ghost au-dessus)
                                    final rawY = _localY(d.offset);
                                    final item = d.data;
                                    final dur  = _proposedDurationFor(item);         // durée réelle du drop
                                    final ghostH = _durationToHeight(dur);           // ✅ aligne avec le visuel du ghost
                                    const spacing = 4.0;
                                    final adjustedY = (rawY - ghostH - spacing).clamp(0.0, _contentHeight() - 1.0);
                                    final snapped = _snapY15(adjustedY);
                                    final t = _yToTime(snapped);
                                    if (_hasOverlap(t, dur)) {
                                      HapticFeedback.heavyImpact();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(context.l10n.genericError ?? "Time slot is already used."),
                                          backgroundColor: Colors.red.shade700,
                                        ),
                                      );
                                      setState(() {
                                        _hoverY = null;
                                        _hoverItem = null;
                                        _canDropHere = true;
                                        _stopAutoScroll();
                                      });
                                      return;
                                    }

                                    setState(() {
                                      _hoverY = null;
                                      _hoverItem = null;
                                      _canDropHere = true;
                                      _stopAutoScroll();
                                    });

                                    // ➕ mémorise la "clé" attendue pour auto-select au prochain rebuild
                                    _pendingTitle = item.name;
                                    _pendingStart = t;

                                    HapticFeedback.lightImpact();

                                    await widget.onCreateStep!(
                                      item: item,
                                      tripDayId: widget.selectedTripDayId!,
                                      day: widget.selectedDay!,
                                      startTime: t,
                                    );
                                  },
                                  builder: (_, __, ___) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                          top: BorderSide(color: AppColors.texasBlue, width: 1),
                                        ),
                                      ),
                                      padding: EdgeInsets.only(bottom: extraScroll),
                                      alignment: Alignment.topLeft,
                                      child: Stack(
                                        children: [
                                          // Bouton "Ajouter une adresse"
                                          if (widget.onAddAddress != null &&
                                              widget.selectedDay != null &&
                                              !widget.hasAddress)
                                            Positioned(
                                              top: 8,
                                              left: 8,
                                              child: TextButton.icon(
                                                onPressed: widget.onAddAddress,
                                                icon: const Icon(Icons.add_location_alt, size: 12),
                                                label: Text(context.l10n.addHotelAddress),
                                                style: TextButton.styleFrom(
                                                  foregroundColor: AppColors.whiteGlow,
                                                  backgroundColor: AppColors.texasBlue,
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                    side: const BorderSide(color: AppColors.texasBlue, width: 1),
                                                  ),
                                                ),
                                              ),
                                            ),

                                          // Steps existants
                                          ...widget.steps.map((s) {
                                            final top = _timeToY(s.start);
                                            final height = _durationToHeight(s.durationMin);
                                            final isSelected = _isSelected(s);
                                            return Positioned(
                                              top: top,
                                              left: 0,
                                              right: 0,
                                              height: height,
                                              child: GestureDetector(
                                                onTap: () => _toggleStepSelection(s),
                                                child: StepCard(
                                                  title: s.title,
                                                  primaryIcon: s.primaryIcon,
                                                  otherIcons: s.otherIcons,
                                                  durationMin: s.durationMin,
                                                  latitude: s.latitude,
                                                  longitude: s.longitude,
                                                  selected: isSelected,
                                                ),
                                              ),
                                            );
                                          }),

                                          // --- Guide de drop (ligne + ghost durée réelle) ---
                                          if (_hoverY != null)
                                            Builder(builder: (_) {
                                              final snapped  = _snapY15(_hoverY!);
                                              final ghostH   = _durationToHeight(_hoverDurationMin); // hauteur = durée réelle
                                              const spacing  = 4.0;

                                              final Color borderCol = _canDropHere ? AppColors.texasBlue : Colors.red;
                                              final Color bgCol     = _canDropHere ? Colors.white       : const Color(0xFFF2F2F4);

                                              return Positioned(
                                                top: math.max(0.0, snapped - ghostH - spacing), // ghost au-dessus de la ligne
                                                left: 0,
                                                right: 0,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: [
                                                    if (_hoverItem != null)
                                                      Opacity(
                                                        opacity: .95,
                                                        child: SizedBox(
                                                          height: ghostH,
                                                          child: StepCard(
                                                            title: _hoverItem!.name,
                                                            durationMin: _hoverDurationMin, // affiche la durée dans le ghost
                                                            bgColor: bgCol,                  // <-- fond gris si overlap
                                                            borderColor: borderCol,          // <-- bord rouge si overlap
                                                          ),
                                                        ),
                                                      ),
                                                    const SizedBox(height: spacing),
                                                    Container(
                                                      height: 2,
                                                      color: _canDropHere
                                                          ? AppColors.texasBlue.withValues(alpha: .55)
                                                          : Colors.red.withValues(alpha: .65),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),

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
          ),
        );
      },
    );
  }
}

class _NoGlowScroll extends ScrollBehavior {
  const _NoGlowScroll();
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}
