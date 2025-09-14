//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/overlay/planning_overlay.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';

import 'package:texas_buddy/features/planning/presentation/cubits/planning_overlay_cubit.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/trip_strip/trips_strip.dart';

// Timeline (steps/hasAddress/selectedDay/onCreateStep/onAddAdress)
import 'package:texas_buddy/features/planning/presentation/widgets/timeline/timeline_pane.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/sheets/address_search_sheet.dart';


// NearbyItem (pour Draggable côté droit)
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';

// Domain entities pour mapper les steps
import 'package:texas_buddy/features/planning/domain/entities/trip_day.dart';
import 'package:texas_buddy/features/planning/domain/entities/trip_step.dart';

// ⬇️ Mapper FA → IconData
import 'package:texas_buddy/core/utils/category_icon_mapper.dart';

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

    // === Sélection du state du cubit ===
    final overlayState = context.watch<PlanningOverlayCubit>().state;
    final TripDay? day = overlayState.selectedDay;

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
        final tod = TimeOfDay(hour: s.startHour, minute: s.startMinute);
        final title = s.target.name;
        print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++ primaryIcon");
        print(s.target.primaryIcon);
        print("attention au otherIcons venant de target");
        print(s.target.otherIcons);
        // Durée: estimatedDurationMinutes > sinon calcul end - start > sinon 60'
        final dyn = s as dynamic;
        int durationMin = 60;
        try {
          print("dans le 1er try");
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
            // évite le doublon si c'est la même que la primaire
            if (primaryIconData == null || ic != primaryIconData) {
              otherIconDatas.add(ic);
            }
          }
        } catch (_) {
          // silencieux
        }

        return TripStepVm(
          start: tod,
          durationMin: durationMin,
          title: title,
          primaryIcon: primaryIconData,
          otherIcons: otherIconDatas,
        );
      }).toList();
    }

    // Colonne droite : branchera plus tard NearbyBloc / vraie data
    final List<NearbyItem> nearbyItems = const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── HEADER FIXE (strip des jours) ───────────────────────────────────
        SizedBox(
          height: topHeight,
          child: Padding(
            padding: EdgeInsets.only(top: stripTopInset),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: widget.width * 0.92),
                child: TripsStrip(height: stripHeight),
              ),
            ),
          ),
        ),

        const SizedBox(height: headerGap),

        // ── BAS (timeline + liste draggable) ────────────────────────────────
        SizedBox(
          height: bottomHeight,
          child: Row(
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
                      stripeFraction: 0.20,

                      // --- données réelles pour la timeline ---
                      steps: stepsVm,
                      hasAddress: hasAddress,
                      selectedDay: selectedDayDate,

                      // ✅ bouton "Ajouter une adresse"
                      onAddAddress: () async {
                        final tripDayId = day?.id;
                        if (tripDayId == null || tripDayId <= 0) {
                          return;
                        }

                        // ✅ Récupérer l'id du trip sélectionné
                        final tripId = context.read<PlanningOverlayCubit>().state.selectedTrip?.id;
                        if (tripId == null || tripId <= 0) {
                          // tu peux afficher un snackbar si tu veux
                          return;
                        }

                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (ctx) => BlocProvider.value(
                            value: context.read<PlanningOverlayCubit>(),
                            child: Padding(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
                              child: AddressSearchSheet(
                                tripId: tripId,
                                tripDayId: tripDayId,
                              ),
                            ),
                          ),
                        );
                      },

                      // --- création d'un step au drop (inchangé) ---
                      onCreateStep: ({required item, required day, required startTime}) async {
                        final d = item as dynamic;
                        await (context.read<PlanningOverlayCubit>() as dynamic).createTripStepFromTarget(
                          day: day,
                          startHour: startTime.hour,
                          startMinute: startTime.minute,
                          targetType: (d.type ?? 'activity') as String,
                          targetId: (d.id as int?) ?? -1,
                          targetName: (d.name as String?) ?? '',
                          placeId: d.placeId as String?,
                          latitude: (d.latitude is num) ? (d.latitude as num).toDouble() : null,
                          longitude: (d.longitude is num) ? (d.longitude as num).toDouble() : null,
                        );
                      },
                    );

                  },
                ),
              ),

              // ==== COLONNE DROITE : LISTE D'ITEMS DRAGGABLES ====
              Expanded(
                child: ScrollConfiguration(
                  behavior: const _NoGlowScroll(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    physics: const BouncingScrollPhysics(),
                    itemCount: nearbyItems.length,
                    itemBuilder: (ctx, i) {
                      final it = nearbyItems[i];
                      final card = _NearbyCard(item: it);

                      return LongPressDraggable<NearbyItem>(
                        data: it,
                        dragAnchorStrategy: pointerDragAnchorStrategy,
                        feedback: Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(12),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (widget.width / 2) - 40,
                              minHeight: 80,
                            ),
                            child: card,
                          ),
                        ),
                        childWhenDragging: Opacity(opacity: .35, child: card),
                        child: card,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoGlowScroll extends ScrollBehavior {
  const _NoGlowScroll();
  @override
  Widget buildOverscrollIndicator(
      BuildContext context,
      Widget child,
      ScrollableDetails details,
      ) =>
      child;
}

class _NearbyCard extends StatelessWidget {
  final NearbyItem item;
  const _NearbyCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.fog,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.texasBlue, width: 1),
        boxShadow: const [
          BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x12000000))
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.place, color: AppColors.texasBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.texasBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
