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
// ⬇️ fichiers extraits
import 'package:texas_buddy/features/planning/presentation/widgets/timeline/timeline_step.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/timeline/add_address_button.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/timeline/travel_badge.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/timeline/no_glow_scroll.dart';
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

    // nouveaux
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

  // gestion boutons delete et modify tripStep
  // index du step dont les actions sont visibles
  int? _actionIndex;
  final GlobalKey _hostKey = GlobalKey();          // pour OutsideDismissBarrier
  late final OutsideDismissBarrier _outsideBarrier;

  double get _gridTopInset => widget.slotHeight * 0.5;

  // Swipe horizontal
  double _dragDx = 0;
  static const _kSwipeDxThreshold = 60.0;
  static const _kSwipeVxThreshold = 400.0;

  // État hover DnD
  double? _hoverY;
  NearbyItem? _hoverItem;

  // Estimation trajet pour le hover courant
  int? _hoverTravelMin;
  int? _hoverTravelMeters;
  TimeOfDay? _hoverMinStart;
  Timer? _travelDebounce;
  bool _didWarnNoHotel = false;      // SnackBar unique si pas d’ancre
  bool _didHapticConstraint = false; // haptique unique quand contrainte s’applique

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
  late final TimelineAutoScroller _autoScroller;

  // UI constants
  static const double _kLineToGhostGap = 4.0; // ghost juste sous la ligne
  static const double _kBadgeHalfHeight = 10.0;

  // ---- Helpers temps <-> pixels ------------------------------------------
  @override
  void initState() {
    super.initState();
    _autoScroller = TimelineAutoScroller(
      controller: _scrollController,
      viewportHeight: () => widget.height,
      hoverY: () => _hoverY,
      onTick: () { if (mounted) setState(() {}); },
      // edge et maxSpeed par défaut = 80 / 900 (identiques à avant)
    );
    _outsideBarrier = OutsideDismissBarrier(
      hostKey: _hostKey,
      onDismiss: _closeStepActions,
    );
  }

  String _langOf(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context);
    return locale?.languageCode.toLowerCase() ?? 'en';
  }

  @override
  void dispose() {
    _autoScroller.dispose();
    _travelDebounce?.cancel();
    _outsideBarrier.hide();
    super.dispose();
  }

  void _focusTripDayIfPossible() {
    if (widget.hasAddress &&
        widget.tripDayLatitude != null &&
        widget.tripDayLongitude != null) {
      context.read<MapFocusCubit>().focusTripDay(
        widget.tripDayLatitude!, widget.tripDayLongitude!, zoom: 12,
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
    return local.dy;
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
  // gestion boutons tripStep
  void _openStepActions(int index) {
    setState(() => _actionIndex = index);
    _outsideBarrier.show(context);
  }

  void _closeStepActions() {
    if (_actionIndex != null) setState(() => _actionIndex = null);
    _outsideBarrier.hide();
  }

  // ✅ utilitaires minutes depuis minuit
  int _toMin(TimeOfDay t) => t.hour * 60 + t.minute;
  TimeOfDay _fromMin(int m) =>
      TimeOfDay(hour: (m ~/ 60).clamp(0, 23), minute: (m % 60).clamp(0, 59));
  TimeOfDay _minusMinutes(TimeOfDay t, int m) =>
      _fromMin((_toMin(t) - m).clamp(0, 23 * 60 + 59));

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

  Future<void> _estimateForHover({
    required TimeOfDay intendedStart,
    required NearbyItem item,
  }) async {
    if (widget.selectedTripDayId == null) return;
    final lat = item.latitude;
    final lng = item.longitude;
    if (lat == null || lng == null) {
      setState(() { _hoverTravelMin = null; _hoverTravelMeters = null; _hoverMinStart = null; });
      return;
    }
    // Lang de l’UI si dispo
    final String lang =_langOf(context);

    final cubit = context.read<PlanningOverlayCubit>();
    final info = await cubit.estimateTravelForHover(
      tripDayId: widget.selectedTripDayId!,
      intendedStart: intendedStart,
      destLat: lat,
      destLng: lng,
      mode: 'driving',
      lang: lang,
    );
    if (!mounted) return;
    if (info == null) {
      setState(() { _hoverTravelMin = null; _hoverTravelMeters = null; _hoverMinStart = null; });
    } else {
      setState(() {
        _hoverTravelMin = info.minutes;
        _hoverTravelMeters = info.meters;
        _hoverMinStart = info.minStart;
      });

      // Info discrète si pas d’hôtel ⇒ pas d’ancre pour un minStart
      if ((_hoverTravelMin ?? 0) == 0 && _hoverMinStart == null && !widget.hasAddress && !_didWarnNoHotel) {
        _didWarnNoHotel = true;
        final txt = context.l10n.addHotelAddress; // “Ajouter l’adresse de l’hôtel”
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(txt),
            backgroundColor: Colors.black87,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ✅ met à jour hover + calcul disponibilité
  void _updateHover(DragTargetDetails<NearbyItem> d) {
    final y = _localY(d.offset);
    final snappedY = _snapY15(y);

    final item = d.data;
    final dur  = _proposedDurationFor(item); // durée réelle (60' par défaut, sinon event)
    final t    = _yToTime(snappedY);

    setState(() {
      _hoverY = y;
      _hoverItem = item;
      _hoverDurationMin = dur;
      _canDropHere = !_hasOverlap(t, dur);
    });

    // Debounce pour éviter de spammer le backend pendant les micro-mouvements
    _travelDebounce?.cancel();
    _travelDebounce = Timer(const Duration(milliseconds: 120), () {
      _estimateForHover(intendedStart: t, item: item);
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
      context.read<MapFocusCubit>().focusTripStep(s.latitude!, s.longitude!, zoom: 12);
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

  // Helpers d'accès dynamiques ---------------------------------------------

  int _extractTravelDurationFromStepVm(TripStepVm s) {
    // 1) si le VM le connaît nativement → on prend
    if (s.travelDurationMinutes != null) {
      return s.travelDurationMinutes!;
    }

    // 2) fallback dynamiques (au cas où le parent passerait un autre type que TripStepVm)
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
                                    _autoScroller.update();
                                    // ✅ bloque l’accept si overlap détecté
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

                                    // on capture TOUT ce qui dépend du context AVANT l'await
                                    final mapFocusCubit = context.read<MapFocusCubit>();

                                    // 🧠 positionnement : la "ligne" suit le doigt (snap 15')
                                    final rawY = _localY(d.offset);
                                    final snappedLine = _snapY15(rawY);

                                    TimeOfDay t = _yToTime(snappedLine + _kLineToGhostGap);

                                    final item = d.data;
                                    final dur  = _proposedDurationFor(item);

                                    if (_hoverMinStart != null) {
                                      final newMin = _toMin(_hoverMinStart!);
                                      final cur    = _toMin(t);
                                      if (cur < newMin) t = _hoverMinStart!;
                                    }

                                    if (_hasOverlap(t, dur)) {
                                      HapticFeedback.heavyImpact();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(context.l10n.genericError),
                                          backgroundColor: Colors.red.shade700,
                                        ),
                                      );
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
                                      return;
                                    }

                                    // couper le ghost tout de suite
                                    setState(() {
                                      _hoverY = null;
                                      _hoverItem = null;
                                    });

                                    HapticFeedback.lightImpact();

                                    // ⬇️ appel async
                                    await widget.onCreateStep!(
                                      item: item,
                                      tripDayId: widget.selectedTripDayId!,
                                      day: widget.selectedDay!,
                                      startTime: t,
                                      travelDurationMinutes: _hoverTravelMin,
                                      travelDistanceMeters: _hoverTravelMeters,
                                    );

                                    // après l'await : on protège les setState
                                    if (!mounted) return;

                                    // focus carte SANS réutiliser context.read(...)
                                    if (hasValidCoords(item.latitude, item.longitude)) {
                                      mapFocusCubit.focusTripStep(
                                        item.latitude, item.longitude, zoom: 16,
                                      );
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
                                    // On construit la pile de widgets dynamiquement pour pouvoir
                                    // insérer les badges entre steps.
                                    final List<Widget> children = [];

                                    // Fond / cadre
                                    children.add(
                                      Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
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


                                    // Steps existants + badge persistant de trajet entre steps (depuis BDD)
                                    for (int i = 0; i < widget.steps.length; i++) {
                                      final s = widget.steps[i];
                                      final top = _timeToY(s.start);
                                      final height = _durationToHeight(s.durationMin);
                                      final isSelected = _isSelected(s);
                                      final bool isActionOpen = _actionIndex == i;

                                      children.add(
                                        Positioned(
                                          top: top,
                                          left: 0,
                                          right: 0,
                                          height: height,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            fit: StackFit.expand, // ⬅️ très important : la Stack prend toute la largeur
                                            children: [
                                              // Carte pleine largeur + gestuelles
                                              GestureDetector(
                                                onTap: () {
                                                  if (isActionOpen) {
                                                    _closeStepActions();
                                                  } else {
                                                    _toggleStepSelection(s);
                                                  }
                                                },
                                                onLongPress: () => _openStepActions(i),
                                                child: SizedBox.expand(            // ⬅️ remplit toute la zone du Positioned
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

                                              // Actions flottantes à droite, MAIS dans la zone timeline
                                              Positioned(
                                                right: 4, // ⬅️ toujours à l’intérieur de la zone de drop
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

                                      // (la suite de ton code travel badge inchangée)
                                      final int travelMin = _extractTravelDurationFromStepVm(s);
                                      if (i > 0 && travelMin > 0) {
                                        final p = widget.steps[i - 1];
                                        final prevEndY = _timeToY(p.start) + _durationToHeight(p.durationMin);
                                        final curTopY  = top;
                                        final midY     = prevEndY + (curTopY - prevEndY) / 2.0;

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



                                    // --- Guide de drop (ghost + ligne + badge au-dessus) ---
                                    if (_hoverY != null) {
                                      final snappedLine = _snapY15(_hoverY!);

                                      // 👉 Ghost top = ligne snap + gap (ghost collé SOUS le doigt)
                                      double ghostTop = snappedLine + _kLineToGhostGap;

                                      // 1) CAS NORMAL : on a un minStart calculé (step précédent connu)
                                      if (_hoverMinStart != null) {
                                        final minY = _timeToY(_hoverMinStart!);
                                        final before = ghostTop;
                                        ghostTop = math.max(ghostTop, minY);
                                        if (!_didHapticConstraint && ghostTop > before) {
                                          HapticFeedback.selectionClick();
                                          _didHapticConstraint = true;
                                        }
                                      }
                                      // 2) 🆕 CAS “PREMIER STEP” : pas de minStart mais on a l’hôtel + une durée de trajet
                                      else if (widget.hasAddress && (_hoverTravelMin ?? 0) > 0) {
                                        // on force au moins après le "trajet" depuis l'hôtel
                                        // (on convertit la durée de trajet en hauteur, même si on ne dessine pas le trajet)
                                        final hotelY = _gridTopInset; // le haut de la journée
                                        final minY = hotelY + _durationToHeight(_hoverTravelMin!);
                                        final before = ghostTop;
                                        ghostTop = math.max(ghostTop, minY);
                                        if (!_didHapticConstraint && ghostTop > before) {
                                          HapticFeedback.selectionClick();
                                          _didHapticConstraint = true;
                                        }
                                      }

                                      final ghostH = _durationToHeight(_hoverDurationMin);

                                      // 🔽 ici on calcule le badge
                                      double? badgeTop;

                                      if ((_hoverTravelMin ?? 0) > 0) {
                                        if (_hoverMinStart != null) {
                                          // ✅ cas existant : step précédent connu
                                          final prevEnd = _minusMinutes(_hoverMinStart!, _hoverTravelMin!);
                                          final yPrevEnd = _timeToY(prevEnd);
                                          final mid = yPrevEnd + (ghostTop - yPrevEnd) / 2.0;
                                          badgeTop = math.max(0.0, mid - _kBadgeHalfHeight);
                                        } else if (widget.hasAddress) {
                                          // ✅ 🆕 cas hôtel → premier step
                                          final hotelY = _gridTopInset; // ancre hôtel
                                          final mid = hotelY + (ghostTop - hotelY) / 2.0;
                                          badgeTop = math.max(0.0, mid - _kBadgeHalfHeight);
                                        }
                                      }

                                      final Color borderCol = _canDropHere ? AppColors.texasBlue : Colors.red;
                                      final Color bgCol     = _canDropHere ? Colors.white       : const Color(0xFFF2F2F4);

                                      children.addAll([
                                        // Ghost (carte) + ligne juste au-dessus
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

                                        // Badge ghost (estimate) au midpoint, au-dessus du ghost
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

