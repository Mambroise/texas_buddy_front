//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/timeline/timeline_pane.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:texas_buddy/core/l10n/l10n_ext.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';

import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';
import 'package:texas_buddy/features/map/presentation/cubits/map_focus_cubit.dart';

import 'package:texas_buddy/features/planning/presentation/cubits/planning_overlay_cubit.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/timeline/hours_list.dart';

import 'package:texas_buddy/features/planning/presentation/widgets/timeline/timeline_step.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/timeline/add_address_button.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/timeline/travel_badge.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/no_glow_scroll.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/timeline/timeline_auto_scroller.dart';

import 'package:texas_buddy/core/utils/outside_dismiss_barrier.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/action_icon_button.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/sheets/confirm_action_sheet.dart';

class TimelinePane extends StatefulWidget {
  final int? selectedTripDayId;
  final Future<bool> Function(TripStepVm step)? onDeleteStep; // retourne true si OK domaine
  final ValueChanged<TripStepVm>? onEditStep;

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

    // data
    this.steps = const <TripStepVm>[],
    this.hasAddress = true,
    this.onAddAddress,
    this.selectedDay,
    this.onCreateStep,
    this.selectedTripDayId,
    this.tripDayLatitude,
    this.tripDayLongitude,
    this.onDeleteStep,
    this.onEditStep,
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

  final List<TripStepVm> steps;
  final bool hasAddress;
  final VoidCallback? onAddAddress;
  final DateTime? selectedDay;
  final CreateStepAtTime? onCreateStep;
  final double? tripDayLatitude;
  final double? tripDayLongitude;

  @override
  State<TimelinePane> createState() => _TimelinePaneState();
}

class _TimelinePaneState extends State<TimelinePane> {
  final _scrollController = ScrollController();
  final _dropKey = GlobalKey();
  bool _isUserScrolling = false;

  // ✅ Actions visibles sur le step (clé stable)
  String? _actionsKey;
  final GlobalKey _hostKey = GlobalKey(); // pour OutsideDismissBarrier
  late final OutsideDismissBarrier _outsideBarrier;

  double get _gridTopInset => widget.slotHeight * 0.5;

  // Swipe horizontal
  double _dragDx = 0;
  static const _kSwipeDxThreshold = 60.0;
  static const _kSwipeVxThreshold = 400.0;

  // ---- DnD CREATE (Nearby -> timeline) ------------------------------------
  double? _hoverY;
  NearbyItem? _hoverItem;
  int? _hoverTravelMin;
  int? _hoverTravelMeters;
  TimeOfDay? _hoverMinStart;
  Timer? _travelDebounce;
  bool _didWarnNoHotel = false;
  bool _didHapticConstraint = false;

  int _hoverDurationMin = 60;
  bool _canDropHere = true;

  // ---- Selection ----------------------------------------------------------
  int? _selectedStepId;
  String? _selectedTitleFallback;
  TimeOfDay? _selectedStartFallback;

  // auto-select après création
  String? _pendingTitle;
  TimeOfDay? _pendingStart;

  // ---- Drag MOVE step (long press) ---------------------------------------
  TripStepVm? _dragStep;
  double? _dragY;                // y local brut
  TimeOfDay? _dragIntended;      // t issu du snap du doigt (avant contrainte)
  TimeOfDay? _dragResolved;      // t final (après minStart)
  int? _dragTravelMin;
  int? _dragTravelMeters;
  TimeOfDay? _dragMinStart;
  bool _dragCanDrop = true;
  bool _dragDidHapticConstraint = false;
  Timer? _dragDebounce;

  // AutoScroll
  late final TimelineAutoScroller _autoScroller;

  // UI constants
  static const double _kLineToGhostGap = 4.0;
  static const double _kBadgeHalfHeight = 10.0;

  @override
  void initState() {
    super.initState();

    _autoScroller = TimelineAutoScroller(
      controller: _scrollController,
      viewportHeight: () => widget.height,
      hoverY: () => _hoverY ?? _dragY,
      onTick: () { if (mounted) setState(() {}); },
    );

    _outsideBarrier = OutsideDismissBarrier(
      hostKey: _hostKey,
      onDismiss: _closeStepActions,
    );
  }

  @override
  void dispose() {
    _autoScroller.dispose();
    _travelDebounce?.cancel();
    _dragDebounce?.cancel();
    _outsideBarrier.hide();
    super.dispose();
  }

  String _langOf(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    return locale?.languageCode.toLowerCase() ?? 'en';
  }

  void _focusTripDayIfPossible() {
    if (widget.hasAddress &&
        widget.tripDayLatitude != null &&
        widget.tripDayLongitude != null) {
      context.read<MapFocusCubit>().focusTripDay(
        widget.tripDayLatitude!,
        widget.tripDayLongitude!,
        zoom: 12,
      );
    }
  }

  // ---- Helpers temps <-> pixels ------------------------------------------
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
    final minutes = (((totalHours - totalHours.floor()) * 60) / 15).round() * 15;
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
    return local.dy;
  }

  // ---- Actions (Delete/Edit) ---------------------------------------------
  String _keyOfStep(TripStepVm s) {
    final id = s.id;
    if (id != null) return 'id:$id';
    return 'fb:${s.title}|${s.start.hour}:${s.start.minute}';
  }

  void _openStepActionsFor(TripStepVm s) {
    setState(() => _actionsKey = _keyOfStep(s));
    _outsideBarrier.show(context);
  }

  void _closeStepActions() {
    if (_actionsKey != null) setState(() => _actionsKey = null);
    _outsideBarrier.hide();
  }

  // ---- Utils minutes ------------------------------------------------------
  int _toMin(TimeOfDay t) => t.hour * 60 + t.minute;
  TimeOfDay _fromMin(int m) =>
      TimeOfDay(hour: (m ~/ 60).clamp(0, 23), minute: (m % 60).clamp(0, 59));
  TimeOfDay _minusMinutes(TimeOfDay t, int m) =>
      _fromMin((_toMin(t) - m).clamp(0, 23 * 60 + 59));

  // ✅ overlap check : exclusion d’un step (drag)
  bool _hasOverlapExcluding({
    required TimeOfDay start,
    required int durationMin,
    int? excludeId,
    String? excludeFallbackKey,
  }) {
    final newStart = _toMin(start);
    final newEnd = newStart + durationMin;

    for (final s in widget.steps) {
      // exclusion
      if (excludeId != null && s.id != null && s.id == excludeId) continue;
      if (excludeId == null && excludeFallbackKey != null && _keyOfStep(s) == excludeFallbackKey) continue;

      final sStart = _toMin(s.start);
      final sEnd = sStart + s.durationMin;
      if (newStart < sEnd && sStart < newEnd) return true;
    }
    return false;
  }

  // ---- DnD create : duration proposed ------------------------------------
  int _proposedDurationFor(NearbyItem it) {
    final dur = it.durationMinutes;
    if (dur != null && dur > 0) return dur.clamp(15, 240);
    if (it.startDateTime != null && it.endDateTime != null) {
      final d = it.endDateTime!.difference(it.startDateTime!).inMinutes;
      return d.clamp(15, 240);
    }
    return 60;
  }

  // ---- Selection ----------------------------------------------------------
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
      context.read<MapFocusCubit>().focusTripStep(
        s.latitude!,
        s.longitude!,
        zoom: 12,
      );
    } else {
      _focusTripDayIfPossible();
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedStepId = null;
      _selectedTitleFallback = null;
      _selectedStartFallback = null;
      _actionsKey = null;
    });
    _outsideBarrier.hide();
    _focusTripDayIfPossible();
  }

  @override
  void didUpdateWidget(covariant TimelinePane old) {
    super.didUpdateWidget(old);

    if (old.selectedTripDayId != widget.selectedTripDayId) {
      _clearSelection();
    }

    // auto-select after create
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

    // si pendant drag le step disparaît / change de day -> stop drag propre
    if (_dragStep != null) {
      final stillThere = widget.steps.any((s) => _keyOfStep(s) == _keyOfStep(_dragStep!));
      if (!stillThere) {
        _stopDragStep(resetHaptics: true);
      }
    }
  }

  // ---- Helpers travel badge dyn ------------------------------------------
  int _extractTravelDurationFromStepVm(TripStepVm s) {
    if (s.travelDurationMinutes != null) return s.travelDurationMinutes!;
    try {
      final dyn = s as dynamic;
      final v1 = dyn.travelDurationMinutes as int?;
      if (v1 != null) return v1;
      final v2 = dyn.travel_duration_minutes as int?;
      if (v2 != null) return v2;
      final v3 = dyn.travelDurationMin as int?;
      if (v3 != null) return v3;
    } catch (_) {}
    return 0;
  }

  // ------------------------------------------------------------------------
  // ✅ CREATE hover : estimate travel (inchangé)
  Future<void> _estimateForHover({
    required TimeOfDay intendedStart,
    required NearbyItem item,
  }) async {
    if (widget.selectedTripDayId == null) return;

    final cubit = context.read<PlanningOverlayCubit>();
    final info = await cubit.estimateTravelForHover(
      tripDayId: widget.selectedTripDayId!,
      intendedStart: intendedStart,
      destLat: item.latitude,
      destLng: item.longitude,
      mode: 'driving',
      lang: _langOf(context),
    );

    if (!mounted) return;

    if (info == null) {
      setState(() {
        _hoverTravelMin = null;
        _hoverTravelMeters = null;
        _hoverMinStart = null;
      });
    } else {
      setState(() {
        _hoverTravelMin = info.minutes;
        _hoverTravelMeters = info.meters;
        _hoverMinStart = info.minStart;
      });

      if ((_hoverTravelMin ?? 0) == 0 &&
          _hoverMinStart == null &&
          !widget.hasAddress &&
          !_didWarnNoHotel) {
        _didWarnNoHotel = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.addHotelAddress),
            backgroundColor: Colors.black87,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _updateHover(DragTargetDetails<NearbyItem> d) {
    final y = _localY(d.offset);
    final snappedY = _snapY15(y);

    final item = d.data;
    final dur = _proposedDurationFor(item);
    final t = _yToTime(snappedY);

    setState(() {
      _hoverY = y;
      _hoverItem = item;
      _hoverDurationMin = dur;
      _canDropHere = !_hasOverlapExcluding(start: t, durationMin: dur);
    });

    _travelDebounce?.cancel();
    _travelDebounce = Timer(const Duration(milliseconds: 120), () {
      _estimateForHover(intendedStart: t, item: item);
    });
  }

  // ------------------------------------------------------------------------
  // ✅ MOVE step (long press drag) : estimate travel (nouveau)
  Future<void> _estimateForDragStep({
    required TripStepVm step,
    required TimeOfDay intendedStart,
  }) async {
    // nécessite un day + un step id idéalement
    if (widget.selectedTripDayId == null) return;

    // si pas de coords (ou pas d’hôtel), on peut quand même drag : travel=0
    if (!step.hasCoords) {
      if (!mounted) return;
      setState(() {
        _dragTravelMin = 0;
        _dragTravelMeters = 0;
        _dragMinStart = null;
      });
      return;
    }

    final cubit = context.read<PlanningOverlayCubit>();

    // 👉 IMPORTANT : on va ajouter côté cubit une méthode dédiée
    // qui ignore le step en cours lors de la recherche du "prev".
    // Signature attendue :
    // estimateTravelForStepMove({tripDayId, movingStepId, intendedStart, destLat, destLng, mode, lang})
    try {
      final info = await (cubit as dynamic).estimateTravelForStepMove(
        tripDayId: widget.selectedTripDayId!,
        movingStepId: step.id,
        intendedStart: intendedStart,
        destLat: step.latitude ?? 0,
        destLng: step.longitude ?? 0,
        mode: 'driving',
        lang: _langOf(context),
      );

      if (!mounted) return;

      if (info == null) {
        setState(() {
          _dragTravelMin = null;
          _dragTravelMeters = null;
          _dragMinStart = null;
        });
      } else {
        setState(() {
          _dragTravelMin = info.minutes as int?;
          _dragTravelMeters = info.meters as int?;
          _dragMinStart = info.minStart as TimeOfDay?;
        });
      }
    } catch (_) {
      // fallback safe
      if (!mounted) return;
      setState(() {
        _dragTravelMin = 0;
        _dragTravelMeters = 0;
        _dragMinStart = null;
      });
    }
  }

  void _startDragStep(TripStepVm s, Offset globalPosition) {
    _closeStepActions(); // ✅ évite glitch
    _selectStep(s);      // ✅ cohérent UX

    final y = _localY(globalPosition);
    final snapped = _snapY15(y);

    final intended = _yToTime(snapped + _kLineToGhostGap);

    setState(() {
      _dragStep = s;
      _dragY = y;
      _dragIntended = intended;
      _dragResolved = intended;
      _dragTravelMin = null;
      _dragTravelMeters = null;
      _dragMinStart = null;
      _dragCanDrop = true;
      _dragDidHapticConstraint = false;
    });

    // auto-scroll
    _autoScroller.update();

    // debounce travel estimate
    _dragDebounce?.cancel();
    _dragDebounce = Timer(const Duration(milliseconds: 120), () {
      _estimateForDragStep(step: s, intendedStart: intended);
    });
  }

  void _updateDragStep(TripStepVm s, Offset globalPosition) {
    final y = _localY(globalPosition);
    final snapped = _snapY15(y);

    final intended = _yToTime(snapped + _kLineToGhostGap);

    // applique la contrainte minStart si connue (comme pour create ghost)
    TimeOfDay resolved = intended;
    if (_dragMinStart != null) {
      if (_toMin(resolved) < _toMin(_dragMinStart!)) {
        resolved = _dragMinStart!;
      }
    }

    final excludeId = s.id;
    final excludeFb = (excludeId == null) ? _keyOfStep(s) : null;
    final canDrop = !_hasOverlapExcluding(
      start: resolved,
      durationMin: s.durationMin,
      excludeId: excludeId,
      excludeFallbackKey: excludeFb,
    );

    setState(() {
      _dragY = y;
      _dragIntended = intended;
      _dragResolved = resolved;
      _dragCanDrop = canDrop;
    });

    _autoScroller.update();

    // haptique si contrainte minStart force un shift
    if (_dragMinStart != null &&
        !_dragDidHapticConstraint &&
        _toMin(resolved) > _toMin(intended)) {
      _dragDidHapticConstraint = true;
      HapticFeedback.selectionClick();
    }

    _dragDebounce?.cancel();
    _dragDebounce = Timer(const Duration(milliseconds: 120), () {
      _estimateForDragStep(step: s, intendedStart: intended);
    });
  }

  Future<void> _endDragStep() async {
    final s = _dragStep;
    if (s == null) return;

    final resolved = _dragResolved ?? s.start;

    // reset ghost tout de suite (UI)
    final bool canDrop = _dragCanDrop;

    _stopDragStep(resetHaptics: false);

    if (!canDrop) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(context.l10n.timeline_drop_occupied),
            backgroundColor: Colors.black87,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }


    // si pas de changement -> no-op
    if (resolved.hour == s.start.hour && resolved.minute == s.start.minute) {
      return;
    }

    // ✅ Commit : on délègue au cubit (à ajouter ensuite)
    // Signature attendue :
    // Future<bool> moveStepFromDrag({required int stepId, required TimeOfDay newStart})
    if (s.id == null) return;

    final cubit = context.read<PlanningOverlayCubit>();
    bool ok = false;
    try {
      ok = await (cubit as dynamic).moveStepFromDrag(
        stepId: s.id,
        newStart: resolved,
        lang: _langOf(context),
      ) as bool;
    } catch (_) {
      ok = false;
    }

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.genericError),
          backgroundColor: Colors.black87,
        ),
      );
    }
  }

  void _stopDragStep({required bool resetHaptics}) {
    _dragDebounce?.cancel();
    setState(() {
      _dragStep = null;
      _dragY = null;
      _dragIntended = null;
      _dragResolved = null;
      _dragTravelMin = null;
      _dragTravelMeters = null;
      _dragMinStart = null;
      _dragCanDrop = true;
      if (resetHaptics) _dragDidHapticConstraint = false;
    });
    _autoScroller.stop();
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

        void onHStart(_) => _dragDx = 0;
        void onHUpdate(DragUpdateDetails d) => _dragDx += d.delta.dx;
        void onHEnd(DragEndDetails d) {
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
          key: _hostKey,
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
                behavior: const NoGlowScroll(),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: stripeH),
                    child: SizedBox(
                      height: stripeH,
                      child: Stack(
                        children: [
                          // 1) Zone timeline (dropW)
                          Align(
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              key: _dropKey,
                              width: dropW,
                              height: stripeH,

                              // ✅ on garde le DragTarget<NearbyItem> intact (create)
                              child: IgnorePointer(
                                ignoring: !widget.expanded,
                                child: DragTarget<NearbyItem>(
                                  onWillAcceptWithDetails: (d) {
                                    _updateHover(d);
                                    _autoScroller.update();
                                    return widget.onCreateStep != null &&
                                        widget.selectedDay != null &&
                                        _canDropHere;
                                  },
                                  onMove: (d) {
                                    _updateHover(d);
                                    _autoScroller.update();
                                  },
                                  onLeave: (_) {
                                    _travelDebounce?.cancel();
                                    setState(() {
                                      _hoverY = null;
                                      _hoverItem = null;
                                      _canDropHere = true;
                                      _hoverTravelMin = null;
                                      _hoverTravelMeters = null;
                                      _hoverMinStart = null;
                                      _didWarnNoHotel = false;
                                      _didHapticConstraint = false;
                                      _autoScroller.stop();
                                    });
                                  },
                                  onAcceptWithDetails: (d) async {
                                    if (widget.onCreateStep == null || widget.selectedDay == null) return;

                                    final mapFocusCubit = context.read<MapFocusCubit>();
                                    final lang = _langOf(context);

                                    final rawY = _localY(d.offset);
                                    final snappedLine = _snapY15(rawY);

                                    TimeOfDay tDrop = _yToTime(snappedLine + _kLineToGhostGap);

                                    final item = d.data;
                                    final dur = _proposedDurationFor(item);

                                    final bool mustHaveTravel =
                                        widget.hasAddress && widget.selectedTripDayId != null;

                                    int? travelMin;
                                    int? travelMeters;
                                    TimeOfDay? minStart;

                                    if (mustHaveTravel) {
                                      final cubit = context.read<PlanningOverlayCubit>();
                                      final info = await cubit.estimateTravelForHover(
                                        tripDayId: widget.selectedTripDayId!,
                                        intendedStart: tDrop,
                                        destLat: item.latitude,
                                        destLng: item.longitude,
                                        mode: 'driving',
                                        lang: lang,
                                      );

                                      if (!mounted) return;

                                      if (info != null) {
                                        travelMin = info.minutes;
                                        travelMeters = info.meters;
                                        minStart = info.minStart;
                                      }
                                    }

                                    TimeOfDay t = tDrop;
                                    if (minStart != null && _toMin(t) < _toMin(minStart)) {
                                      t = minStart;
                                    }

                                    if (_hasOverlapExcluding(start: t, durationMin: dur)) {
                                      HapticFeedback.heavyImpact();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(context.l10n.timeline_drop_occupied),
                                          backgroundColor: Colors.black87,
                                        ),
                                      );
                                      setState(() {
                                        _hoverY = null;
                                        _hoverItem = null;
                                        _canDropHere = true;
                                        _canDropHere = true;
                                        _hoverTravelMin = null;
                                        _hoverTravelMeters = null;
                                        _hoverMinStart = null;
                                        _didWarnNoHotel = false;
                                        _didHapticConstraint = false;
                                        _autoScroller.stop();
                                      });
                                      return;
                                    }

                                    setState(() {
                                      _hoverY = null;
                                      _hoverItem = null;
                                    });

                                    HapticFeedback.lightImpact();

                                    await widget.onCreateStep!(
                                      item: item,
                                      tripDayId: widget.selectedTripDayId!,
                                      day: widget.selectedDay!,
                                      startTime: t,
                                      travelDurationMinutes: travelMin,
                                      travelDistanceMeters: travelMeters,
                                    );

                                    if (!mounted) return;

                                    if (hasValidCoords(item.latitude, item.longitude)) {
                                      mapFocusCubit.focusTripStep(item.latitude, item.longitude, zoom: 16);
                                    }

                                    setState(() {
                                      _canDropHere = true;
                                      _hoverTravelMin = null;
                                      _hoverTravelMeters = null;
                                      _hoverMinStart = null;
                                      _didWarnNoHotel = false;
                                      _didHapticConstraint = false;
                                      _autoScroller.stop();
                                    });

                                    _pendingTitle = item.name;
                                    _pendingStart = t;
                                  },

                                  builder: (_, __, ___) {
                                    final List<Widget> children = [];

                                    // Fond / cadre
                                    children.add(
                                      Container(
                                        decoration: BoxDecoration(
                                          color: widget.stripeColor,
                                          border: Border(
                                            top: BorderSide(color: AppColors.texasBlue, width: 1),
                                          ),
                                        ),
                                        alignment: Alignment.topLeft,
                                        padding: EdgeInsets.only(bottom: widget.height * 0.50),
                                      ),
                                    );

                                    // Bouton "Ajouter une adresse"
                                    if (widget.onAddAddress != null &&
                                        widget.selectedDay != null &&
                                        !widget.hasAddress) {
                                      children.add(
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: AddAddressButton(onPressed: widget.onAddAddress),
                                        ),
                                      );
                                    }

                                    // Steps + travel badges persistants (inchangé)
                                    for (int i = 0; i < widget.steps.length; i++) {
                                      final s = widget.steps[i];
                                      final top = _timeToY(s.start);
                                      final height = _durationToHeight(s.durationMin);

                                      final isSelected = _isSelected(s);
                                      final isActionOpen = (_actionsKey != null && _actionsKey == _keyOfStep(s));

                                      children.add(
                                        Positioned(
                                          top: top,
                                          left: 0,
                                          right: 0,
                                          height: height,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            fit: StackFit.expand,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  // ✅ Tap : select + actions
                                                  if (!isSelected) {
                                                    _selectStep(s);
                                                    _openStepActionsFor(s);
                                                    return;
                                                  }
                                                  // déjà selected : toggle actions
                                                  if (isActionOpen) {
                                                    _closeStepActions();
                                                  } else {
                                                    _openStepActionsFor(s);
                                                  }
                                                },

                                                // ✅ LongPress = drag (nouveau)
                                                onLongPressStart: (d) {
                                                  if (!widget.expanded) return;
                                                  _startDragStep(s, d.globalPosition);
                                                },
                                                onLongPressMoveUpdate: (d) {
                                                  if (_dragStep == null) return;
                                                  _updateDragStep(s, d.globalPosition);
                                                },
                                                onLongPressEnd: (_) async {
                                                  if (_dragStep == null) return;
                                                  await _endDragStep();
                                                },

                                                child: SizedBox.expand(
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
                                              ),

                                              // Actions flottantes (inchangé)
                                              Positioned(
                                                right: 4,
                                                top: -8,
                                                child: AnimatedOpacity(
                                                  duration: const Duration(milliseconds: 150),
                                                  opacity: isActionOpen ? 1 : 0,
                                                  child: AnimatedSlide(
                                                    duration: const Duration(milliseconds: 180),
                                                    curve: Curves.easeOut,
                                                    offset: isActionOpen ? Offset.zero : const Offset(0.3, 0.0),
                                                    child: Column(
                                                      children: [
                                                        ActionIconButton(
                                                          icon: Icons.delete,
                                                          bg: Colors.red.shade50,
                                                          fg: Colors.red.shade700,
                                                          tooltip: context.l10n.trips_actions_delete_tooltip,
                                                          onTap: () async {
                                                            _outsideBarrier.pause();

                                                            final ok = await showConfirmActionSheet(
                                                              context,
                                                              title: context.l10n.timeline_delete_title,
                                                              message: context.l10n.timeline_delete_message(s.title),
                                                              cancelLabel: context.l10n.common_cancel,
                                                              confirmLabel: context.l10n.trips_delete_confirm,
                                                              icon: Icons.warning_amber_rounded,
                                                              confirmBg: Colors.red.shade50,
                                                              confirmFg: Colors.red.shade800,
                                                            );

                                                            _outsideBarrier.resume();

                                                            if (ok == true && mounted && widget.onDeleteStep != null) {
                                                              final messenger = ScaffoldMessenger.of(context);
                                                              final success = await widget.onDeleteStep!(s);
                                                              if (!mounted) return;

                                                              messenger.showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    success
                                                                        ? context.l10n.trips_delete_success
                                                                        : context.l10n.trips_delete_error,
                                                                  ),
                                                                ),
                                                              );
                                                              _closeStepActions();
                                                            }
                                                          },
                                                        ),
                                                        const SizedBox(height: 12),
                                                        ActionIconButton(
                                                          icon: Icons.edit,
                                                          bg: Colors.blue.shade50,
                                                          fg: AppColors.texasBlue,
                                                          tooltip: context.l10n.trips_actions_edit_tooltip,
                                                          onTap: () {
                                                            widget.onEditStep?.call(s);
                                                            _closeStepActions();
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );

                                      // TravelBadge persistants (⚠️ inchangé)
                                      final int travelMin = _extractTravelDurationFromStepVm(s);

                                      if (i > 0 && travelMin > 0) {
                                        final p = widget.steps[i - 1];
                                        final prevEndY = _timeToY(p.start) + _durationToHeight(p.durationMin);
                                        final curTopY = top;
                                        final midY = prevEndY + (curTopY - prevEndY) / 2.0;

                                        children.add(
                                          Positioned(
                                            top: math.max(0.0, midY - _kBadgeHalfHeight),
                                            left: 4,
                                            child: TravelBadge(minutes: travelMin),
                                          ),
                                        );
                                      }

                                      if (i == 0 && widget.hasAddress && travelMin > 0) {
                                        final midY = top / 2.0;
                                        children.add(
                                          Positioned(
                                            top: math.max(0.0, midY - _kBadgeHalfHeight),
                                            left: 4,
                                            child: TravelBadge(minutes: travelMin),
                                          ),
                                        );
                                      }
                                    }

                                    // ------------------------------------------------------------------
                                    // ✅ GHOST pour MOVE (drag step) — en PLUS, sans toucher aux badges persistants
                                    if (_dragStep != null && _dragResolved != null) {
                                      final s = _dragStep!;
                                      final resolved = _dragResolved!;
                                      final snappedLine = _snapY15(_dragY ?? _timeToY(resolved));

                                      double ghostTop = snappedLine + _kLineToGhostGap;

                                      // contraint par minStart (visuel identique au create)
                                      if (_dragMinStart != null) {
                                        final minY = _timeToY(_dragMinStart!);
                                        ghostTop = math.max(ghostTop, minY);
                                      }

                                      final ghostH = _durationToHeight(s.durationMin);

                                      // badge midpoint (travel estimé)
                                      double? badgeTop;
                                      if ((_dragTravelMin ?? 0) > 0) {
                                        if (_dragMinStart != null) {
                                          final prevEnd = _minusMinutes(_dragMinStart!, _dragTravelMin!);
                                          final yPrevEnd = _timeToY(prevEnd);
                                          final mid = yPrevEnd + (ghostTop - yPrevEnd) / 2.0;
                                          badgeTop = math.max(0.0, mid - _kBadgeHalfHeight);
                                        } else if (widget.hasAddress) {
                                          final hotelY = _gridTopInset;
                                          final mid = hotelY + (ghostTop - hotelY) / 2.0;
                                          badgeTop = math.max(0.0, mid - _kBadgeHalfHeight);
                                        }
                                      }

                                      final Color borderCol = _dragCanDrop ? AppColors.texasBlue : Colors.red;
                                      final Color bgCol = _dragCanDrop ? Colors.white : const Color(0xFFF2F2F4);

                                      children.addAll([
                                        // Ghost + ligne
                                        Positioned(
                                          top: ghostTop,
                                          left: 0,
                                          right: 0,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Opacity(
                                                opacity: .95,
                                                child: SizedBox(
                                                  height: ghostH,
                                                  child: StepCard(
                                                    title: s.title,
                                                    durationMin: s.durationMin,
                                                    primaryIcon: s.primaryIcon,
                                                    otherIcons: s.otherIcons,
                                                    bgColor: bgCol,
                                                    borderColor: borderCol,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: _kLineToGhostGap),
                                              Container(
                                                height: 2,
                                                color: _dragCanDrop
                                                    ? AppColors.texasBlue.withValues(alpha: .55)
                                                    : Colors.red.withValues(alpha: .65),
                                              ),
                                            ],
                                          ),
                                        ),

                                        if (badgeTop != null)
                                          Positioned(
                                            top: badgeTop,
                                            left: 4,
                                            child: TravelBadge(minutes: _dragTravelMin!),
                                          ),
                                      ]);
                                    }

                                    // ------------------------------------------------------------------
                                    // ✅ GHOST pour CREATE (hover Nearby) — inchangé
                                    if (_hoverY != null) {
                                      final snappedLine = _snapY15(_hoverY!);

                                      double ghostTop = snappedLine + _kLineToGhostGap;

                                      if (_hoverMinStart != null) {
                                        final minY = _timeToY(_hoverMinStart!);
                                        final before = ghostTop;
                                        ghostTop = math.max(ghostTop, minY);
                                        if (!_didHapticConstraint && ghostTop > before) {
                                          HapticFeedback.selectionClick();
                                          _didHapticConstraint = true;
                                        }
                                      } else if (widget.hasAddress && (_hoverTravelMin ?? 0) > 0) {
                                        final hotelY = _gridTopInset;
                                        final minY = hotelY + _durationToHeight(_hoverTravelMin!);
                                        final before = ghostTop;
                                        ghostTop = math.max(ghostTop, minY);
                                        if (!_didHapticConstraint && ghostTop > before) {
                                          HapticFeedback.selectionClick();
                                          _didHapticConstraint = true;
                                        }
                                      }

                                      final ghostH = _durationToHeight(_hoverDurationMin);

                                      double? badgeTop;
                                      if ((_hoverTravelMin ?? 0) > 0) {
                                        if (_hoverMinStart != null) {
                                          final prevEnd = _minusMinutes(_hoverMinStart!, _hoverTravelMin!);
                                          final yPrevEnd = _timeToY(prevEnd);
                                          final mid = yPrevEnd + (ghostTop - yPrevEnd) / 2.0;
                                          badgeTop = math.max(0.0, mid - _kBadgeHalfHeight);
                                        } else if (widget.hasAddress) {
                                          final hotelY = _gridTopInset;
                                          final mid = hotelY + (ghostTop - hotelY) / 2.0;
                                          badgeTop = math.max(0.0, mid - _kBadgeHalfHeight);
                                        }
                                      }

                                      final Color borderCol = _canDropHere ? AppColors.texasBlue : Colors.red;
                                      final Color bgCol = _canDropHere ? Colors.white : const Color(0xFFF2F2F4);

                                      children.addAll([
                                        Positioned(
                                          top: ghostTop,
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
                                                      durationMin: _hoverDurationMin,
                                                      bgColor: bgCol,
                                                      borderColor: borderCol,
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(height: _kLineToGhostGap),
                                              Container(
                                                height: 2,
                                                color: _canDropHere
                                                    ? AppColors.texasBlue.withValues(alpha: .55)
                                                    : Colors.red.withValues(alpha: .65),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (badgeTop != null)
                                          Positioned(
                                            top: badgeTop,
                                            left: 4,
                                            child: TravelBadge(minutes: _hoverTravelMin!),
                                          ),
                                      ]);
                                    }

                                    return Stack(children: children);
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
                              onHorizontalDragStart: onHStart,
                              onHorizontalDragUpdate: onHUpdate,
                              onHorizontalDragEnd: onHEnd,
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
