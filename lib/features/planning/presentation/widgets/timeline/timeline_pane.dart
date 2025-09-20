//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/timeline/timeline_pane.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/core/l10n/l10n_ext.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/hours_list.dart';
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';
import 'package:texas_buddy/features/map/presentation/cubits/map_focus_cubit.dart';



class TripStepVm {
  final int? id;
  final TimeOfDay start;
  final int durationMin;
  final String title;

  final double? latitude;
  final double? longitude;

  /// Icônes déjà résolues (plus de mapping ici)
  final IconData? primaryIcon;
  final List<IconData> otherIcons;

  const TripStepVm({
    this.id,
    required this.start,
    required this.durationMin,
    required this.title,
    this.latitude,
    this.longitude,
    this.primaryIcon,
    this.otherIcons = const <IconData>[],
  });
}

typedef CreateStepAtTime = Future<void> Function({
required NearbyItem item,
required int tripDayId,          // ✅ NOUVEAU
required DateTime day,
required TimeOfDay startTime,
});

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

  int? _selectedStepId;                 // sélection par id si dispo
  String? _selectedTitleFallback;       // fallback si pas d'id
  TimeOfDay? _selectedStartFallback;

  // Clé du step qui vient d’être créé (pour l’auto-select après rebuild)
  String? _pendingTitle;                // on se base sur (title + start)
  TimeOfDay? _pendingStart;


  // ---- Helpers temps <-> pixels ------------------------------------------

  bool _hasValidCoords(double? lat, double? lng) =>
      lat != null && lng != null && lat.abs() > 0.0001 && lng.abs() > 0.0001;

  // Focus helper
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
    final quarterH = widget.slotHeight / 4.0;      // 15'
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
    // + inset pour aligner sur la ligne "centrée" d'HoursList
    return (h * widget.slotHeight) + (t.minute / 60.0) * widget.slotHeight + _gridTopInset;
  }

  double _durationToHeight(int minutes) {
    final h = (minutes / 60.0) * widget.slotHeight;
    // hauteur mini pour rester lisible
    return h.clamp(28.0, widget.slotHeight * 4); // min 28px, max 4h
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
  bool _isSelected(TripStepVm s) {
    if (_selectedStepId != null && s.id != null) {
      return s.id == _selectedStepId;
    }
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

    if (_hasValidCoords(s.latitude, s.longitude)) {
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

    // Changement de TripDay → reset sélection et focus TripDay
    if (old.selectedTripDayId != widget.selectedTripDayId) {
      _clearSelection();
    }

// Auto-select du *dernier step créé* (match sur pending title+start)
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
                  child: ConstrainedBox( // (2) s’assure qu’on a toujours un minimum de hauteur
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
                                    final snapped = _snapY15(y);
                                    final t = _yToTime(snapped);
                                    final item = d.data;
                                    setState(() {
                                      _hoverY = null;
                                      _hoverItem = null;
                                    });

                                      // ➕ mémorise la "clé" attendue pour auto-select au prochain rebuild
                                    _pendingTitle = item.name;
                                    _pendingStart = t;

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
                                        color: Colors.white, // fond clair pour bien voir
                                        border: Border(
                                          top: BorderSide(color: AppColors.texasBlue, width: 1),
                                        ),
                                      ),
                                      padding: EdgeInsets.only(bottom: extraScroll),
                                      alignment: Alignment.topLeft,
                                      child: Stack(
                                        children: [
                                          // --- Bouton "Ajouter une adresse" en overlay, sans date ---
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

                                          // --- Steps existants ---
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
                                                child: _StepCard(
                                                  title: s.title,
                                                  primaryIcon: s.primaryIcon,
                                                  otherIcons: s.otherIcons,
                                                  durationMin: s.durationMin,
                                                  latitude: s.latitude,
                                                  longitude: s.longitude,
                                                  selected: isSelected,             // ✅
                                                ),
                                              ),
                                            );
                                          }),

                                          // --- Guide de drop (ligne + ghost 60') ---
                                          if (_hoverY != null)
                                            Positioned(
                                              top: _snapY15(_hoverY!),
                                              left: 0,
                                              right: 0,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: [
                                                  Container(height: 2, color: AppColors.texasBlue.withValues(alpha: .55)),
                                                  const SizedBox(height: 4),
                                                  if (_hoverItem != null)
                                                    Opacity(
                                                      opacity: .85,
                                                      child: SizedBox(
                                                        height: _durationToHeight(60),
                                                        child: _StepCard(title: _hoverItem!.name),
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
          ),
        );
      },
    );
  }

}

class _StepCard extends StatelessWidget {
  final String title;
  final IconData? primaryIcon;
  final List<IconData> otherIcons;
  final int? durationMin;
  final double? latitude;
  final double? longitude;
  final bool selected;

  const _StepCard({
    required this.title,
    this.primaryIcon,
    this.otherIcons = const [],
    this.durationMin,
    this.latitude,
    this.longitude,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFF3F3) : Colors.white,
        border: Border.all(
          color: selected ? AppColors.texasRedGlow : AppColors.texasBlue,
          width: selected ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(blurRadius: 12, offset: Offset(0, 6), color: Color(0x24000000)),
          BoxShadow(blurRadius: 24, offset: Offset(0, 12), color: Color(0x14000000)),
        ],
      ),

      // ⬇️ this viewport prevents RenderFlex overflow; it won’t be scrollable
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // be polite inside the viewport
          children: [
            // Titre
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w800, fontSize: 10),
            ),
            const SizedBox(height: 6),

            // Icônes
            if (primaryIcon != null || otherIcons.isNotEmpty)
              Wrap(
                spacing: 10,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  if (primaryIcon != null) Icon(primaryIcon, size: 10, color: AppColors.texasRedGlow),
                  ...otherIcons.map((ic) => Icon(ic, size: 10, color: AppColors.black)),
                ],
              ),

            // Durée
            if (durationMin != null) ...[
              const SizedBox(height: 6),
              Text('${durationMin} min', style: TextStyle(fontSize: 10, color: AppColors.black)),
            ],

            // Lat/Lng (petit, discret)
            if (latitude != null && longitude != null) ...[
              const SizedBox(height: 4),
              Text(
                '(${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)})',
                style: const TextStyle(fontSize: 9, color: Colors.black54),
              ),
            ],
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
