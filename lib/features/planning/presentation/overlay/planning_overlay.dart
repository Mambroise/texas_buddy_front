//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/overlay/planning_overlay.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';

import 'package:texas_buddy/core/l10n/l10n_ext.dart';
import 'package:texas_buddy/features/planning/presentation/cubits/planning_overlay_cubit.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/trip_strip/trips_strip.dart';

// Timeline (steps/hasAddress/selectedDay/onCreateStep/onAddAdress)
import 'package:texas_buddy/features/planning/presentation/widgets/timeline/timeline_pane.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/timeline/timeline_step.dart';

import 'package:texas_buddy/features/planning/presentation/widgets/sheets/address_search_sheet.dart';

// NearbyItem (pour Draggable côté droit)
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/nearby/nearby_draggable_list.dart';

// Domain entities pour mapper les steps
import 'package:texas_buddy/features/planning/domain/entities/trip_day.dart';
import 'package:texas_buddy/features/planning/domain/entities/trip_step.dart';

// ⬇️ Mapper FA → IconData
import 'package:texas_buddy/core/utils/category_icon_mapper.dart';

import 'package:texas_buddy/features/planning/presentation/widgets/trip_strip/trip_strip-bend.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/sheets/edit_step_duration_sheet.dart';



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
  // --- Helpers Nearby → backend fields ------------------------------------

  String _typeFromKind(NearbyItem it) {
    final k = it.kind.toString().toLowerCase();
    return k.contains('event') ? 'event' : 'activity';
  }

  int _defaultDurationMinFor(NearbyItem it) {
    final d = it.durationMinutes;
    if (d != null && d > 0) return d.clamp(15, 240);

    if (it.startDateTime != null && it.endDateTime != null) {
      final m = it.endDateTime!.difference(it.startDateTime!).inMinutes;
      return m.clamp(15, 240);
    }
    return 60;
  }



  List<String> _otherIconKeysOf(NearbyItem it) {
    final primary = it.primaryCategory?.trim();
    final cats = it.categories;
    if (cats.isEmpty) return const [];
    final out = <String>[];
    final seen = <String>{};
    for (final raw in cats) {
      final key = raw.trim();
      if (key.isEmpty) continue;
      if (primary != null && key == primary) continue;
      if (seen.add(key)) out.add(key);
    }
    return out;
  }

  // ------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    const double headerGap = 0.0;
    final double topHeight = widget.height / 4;
    const double kStripTopInsetFrac = 0.20;
    final double stripTopInset = topHeight * kStripTopInsetFrac;
    final double stripHeight = topHeight - stripTopInset;

    final double bottomHeight = widget.height - topHeight - headerGap;

    const int firstHour = 6;
    const int lastHour = 23;

    final String lang =
    Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) == null
        ? 'en'
        : Localizations.localeOf(context).languageCode.toLowerCase();
    final bool use24h = !(lang == 'en' || lang == 'es');

    final bool useMiles = (lang == 'en' || lang == 'es');

    // === Sélection du state du cubit ===
    final overlayState = context.watch<PlanningOverlayCubit>().state;
    final TripDay? day = overlayState.selectedDay;
    final bool hasOpenTrip = overlayState.selectedTrip != null;


    // map TripStep → TripStepVm (tri + durée + icônes)
    List<TripStepVm> stepsVm = const [];
    bool hasAddress = false;
    DateTime? selectedDayDate;

    if (day != null) {
      selectedDayDate = day.date;
      hasAddress = (day.address?.trim().isNotEmpty ?? false);

      final sorted = List<TripStep>.from(day.steps)
        ..sort((a, b) {
          final ai = a.startHour * 60 + a.startMinute;
          final bi = b.startHour * 60 + b.startMinute;
          return ai.compareTo(bi);
        });

      stepsVm = sorted.map((s) {
        // Durée: estimatedDurationMinutes > sinon calcul end - start > sinon 60'
        int durationMin = 60;
        try {
          final dyn = s as dynamic;
          durationMin = (dyn.estimatedDurationMinutes as int?) ??
              ((dyn.endHour is int && dyn.endMinute is int)
                  ? ((dyn.endHour as int) * 60 +
                  (dyn.endMinute as int) -
                  (s.startHour * 60 + s.startMinute))
                  : 60);
        } catch (_) {
          durationMin = 60;
        }
        if (durationMin <= 0) durationMin = 60;

        // --- Icônes catégories → IconData ---------------------------------
        IconData? primaryIconData;
        final List<IconData> otherIconDatas = <IconData>[];

        try {
          final primaryIconStr = s.target.primaryIcon;
          if (primaryIconStr != null && primaryIconStr.trim().isNotEmpty) {
            primaryIconData = CategoryIconMapper.map(primaryIconStr);
          }

          for (final iconStr in s.target.otherIcons) {
            if (iconStr.trim().isEmpty) continue;
            final ic = CategoryIconMapper.map(iconStr);
            if (primaryIconData == null || ic != primaryIconData) {
              otherIconDatas.add(ic);
            }
          }
        } catch (_) {
          // silencieux
        }

        return TripStepVm(
          id: s.id,
          start: TimeOfDay(hour: s.startHour, minute: s.startMinute),
          durationMin: durationMin,
          title: s.target.name,
          latitude: (s.target.latitude == 0) ? null : s.target.latitude,
          longitude: (s.target.longitude == 0) ? null : s.target.longitude,
          travelDurationMinutes: s.travelDurationMinutes,
          primaryIcon: primaryIconData,
          otherIcons: otherIconDatas,
        );
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── HEADER FIXE (strip des jours) ───────────────────────────────────
        SizedBox(
          height: topHeight,
          child: Padding(
            padding: EdgeInsets.only(top: stripTopInset),
            child: TripStripBand(
              height: stripHeight,
              margin: const EdgeInsets.symmetric(vertical: 8), // ⬅️ marge haut/bas
              child: TripsStrip(height: stripHeight),
            ),
          ),
        ),

        const SizedBox(height: headerGap),

        // ── BAS (timeline + liste draggable) ────────────────────────────────
        SizedBox(
          height: bottomHeight,
          child:  hasOpenTrip
              ? Row(
            children: [
              // ==== COLONNE GAUCHE : TIMELINE (drop zone) ====
              Expanded(
                child: BlocBuilder<PlanningOverlayCubit, PlanningOverlayState>(
                  // rebuild si expanded OU selectedDay OU selectedTrip change
                  buildWhen: (p, n) =>
                  p.expanded != n.expanded ||
                      p.selectedDay != n.selectedDay ||
                      p.selectedTrip != n.selectedTrip,
                  builder: (context, ovr) {
                    return TimelinePane(
                      height: bottomHeight,
                      firstHour: firstHour,
                      lastHour: lastHour,
                      slotHeight: widget.slotHeight,
                      use24h: use24h,
                      stripeColor: widget.stripeColor,
                      hourTextColor: widget.hourTextColor,
                      expanded: ovr.expanded,
                      onToggleTap: widget.onToggleTap,
                      onRequestExpanded: (expand) {
                        final c = context.read<PlanningOverlayCubit>();
                        expand ? c.expand() : c.collapse();
                      },
                      stripeFraction: 0.15,

                      // --- données réelles pour la timeline ---
                      steps: stepsVm,
                      hasAddress: hasAddress,
                      selectedDay: selectedDayDate,
                      tripDayLatitude: day?.latitude,
                      tripDayLongitude: day?.longitude,
                      selectedTripDayId: day?.id, // ✅ nécessaire pour créer le step au bon endroit

                      // ✅ bouton "Ajouter une adresse"
                      onAddAddress: () async {
                        final tripDayId = day?.id;
                        if (tripDayId == null || tripDayId <= 0) return;

                        final tripId =
                            context.read<PlanningOverlayCubit>().state.selectedTrip?.id;
                        if (tripId == null || tripId <= 0) return;

                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (ctx) => BlocProvider.value(
                            value: context.read<PlanningOverlayCubit>(),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(ctx).viewInsets.bottom),
                              child: AddressSearchSheet(
                                tripId: tripId,
                                tripDayId: tripDayId,
                              ),
                            ),
                          ),
                        );
                      },
                      onDeleteStep: (step) async {
                        // appelle ton usecase / cubit de suppression, retourne true si succès
                        // Exemple si tu as une méthode dédiée :
                        return await context.read<PlanningOverlayCubit>().deleteStep(step.id!);
                      },
                      onEditStep: (step) async {
                        if (step.id == null) return;

                        final newDuration = await showModalBottomSheet<int>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (ctx) => EditStepDurationSheet(
                            title: step.title,
                            initialDurationMinutes: step.durationMin,
                          ),
                        );

                        if (newDuration == null || newDuration <= 0) return;

                        final cubit = context.read<PlanningOverlayCubit>();
                        final ok = await cubit.updateStepFromEditor(
                          stepId: step.id!,
                          newDurationMinutes: newDuration,
                        );

                        if (!context.mounted) return;

                        final messenger = ScaffoldMessenger.of(context);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? context.l10n.timeline_edit_success
                                  : context.l10n.timeline_edit_error,
                            ),
                          ),
                        );
                      },


                      // --- création d'un step au drop ---
                      onCreateStep: ({
                        required NearbyItem item,
                        required int tripDayId,
                        required DateTime day,
                        required TimeOfDay startTime,
                        int? travelDurationMinutes,
                        int? travelDistanceMeters,
                      }) async {
                        final tripId =
                            context.read<PlanningOverlayCubit>().state.selectedTrip?.id;
                        if (tripId == null) return;

                        final targetType =
                        _typeFromKind(item); // "activity" | "event"
                        final targetId = int.tryParse(item.id) ??
                            -1; // si id est String dans le domain
                        final targetName = item.name;
                        final durationMin = _defaultDurationMinFor(item);
                        final primaryIcon =
                            item.primaryCategory; // clé FA "fa-xxx" si dispo
                        final otherIcons =
                        _otherIconKeysOf(item); // autres clés FA
                        final lat = item.latitude;
                        final lng = item.longitude;

                        await (context.read<PlanningOverlayCubit>() as dynamic)
                            .createTripStepFromTarget(
                          tripId: tripId,
                          tripDayId: tripDayId,
                          startHour: startTime.hour,
                          startMinute: startTime.minute,
                          estimatedDurationMinutes: durationMin,
                          targetType: targetType,
                          targetId: targetId,
                          targetName: targetName,
                          primaryIcon: primaryIcon,
                          otherIcons: otherIcons,
                          latitude: lat,
                          longitude: lng,
                          travelDurationMinutes: travelDurationMinutes,
                          travelDistanceMeters: travelDistanceMeters,
                        );
                      },
                    );
                  },
                ),
              ),

              // ==== COLONNE DROITE : LISTE D'ITEMS DRAGGABLES ====
              Expanded(
                child: BlocBuilder<PlanningOverlayCubit, PlanningOverlayState>(
                  buildWhen: (p, n) => p.expanded != n.expanded,
                  builder: (context, ovr) {
                    final bool expanded = ovr.expanded;

                    return AnimatedSlide(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      offset: Offset(expanded ? 0.0 : 0.75, 0.0),
                      child: NearbyDraggableList(
                        maxCardWidth: (widget.width / 2) - 40,
                        useMiles: useMiles, // ⬅️ passe le flag
                      ),
                    );
                  },
                ),
              ),
            ],
          ) : Align(
            alignment: const Alignment(0, -0.5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: widget.stripeColor.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.texasBlue, width: 1),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 12,
                    offset: Offset(0, 4),
                    color: Color(0x22000000),
                  ),
                ],
              ),
              child: Text(
                context.l10n.planning_select_trip_hint,
                style: const TextStyle(
                  color: AppColors.texasBlue,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
