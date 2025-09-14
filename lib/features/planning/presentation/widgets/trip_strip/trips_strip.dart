//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/trip_strip/trips_strip.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:texas_buddy/core/l10n/l10n_ext.dart';

import 'package:texas_buddy/features/planning/domain/entities/trip.dart';
import 'package:texas_buddy/features/planning/presentation/blocs/trips/trips_state.dart';
import 'package:texas_buddy/features/planning/presentation/cubits/trips_cubit.dart';
import 'package:texas_buddy/features/planning/presentation/cubits/planning_overlay_cubit.dart';

// 👇 nos deux sous-vues
import 'package:texas_buddy/features/planning/presentation/widgets/trip_strip/trips_cards_strip.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/trip_strip/trips_days_wheel.dart';

// Bottom sheets wrappers
import 'package:texas_buddy/features/planning/presentation/widgets/sheets/trip_create_wrapper.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/sheets/trip_edit_wrapper.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/sheets/trip_draft.dart';

class TripsStrip extends StatefulWidget {
  final double height;
  const TripsStrip({super.key, required this.height});

  @override
  State<TripsStrip> createState() => _TripsStripState();
}

class _TripsStripState extends State<TripsStrip> {
  Trip? _focusedTrip;
  bool _loading = false;


  Future<void> _openCreateFlow(BuildContext context) async {
    final draft = await showModalBottomSheet<TripDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: TripCreateWrapper(onSubmit: (d) => Navigator.of(ctx).pop(d)),
      ),
    );
    if (draft != null && mounted) {
      await context.read<TripsCubit>().create(
        title: draft.title,
        startDate: draft.range.start,
        endDate: draft.range.end,
        adults: draft.adults,
        children: draft.children,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.trips_create_success)),
      );
    }
  }

  Future<void> _openEditFlow(BuildContext context, Trip t) async {
    final draft = await showModalBottomSheet<TripDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: TripEditWrapper(trip: t, onSubmit: (d) => Navigator.of(ctx).pop(d)),
      ),
    );
    if (draft != null && mounted) {
      final ok = await context.read<TripsCubit>().update(
        id: t.id,
        title: draft.title,
        startDate: draft.range.start,
        endDate: draft.range.end,
        adults: draft.adults,
        children: draft.children,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? context.l10n.trips_update_success : context.l10n.trips_update_error)),
      );
    }
  }

  // charge le trip détaillé, alimente l’overlay, puis ouvre la roue
  Future<void> _onTripSelected(Trip t) async {
    setState(() => _loading = true);
    try {
      final full = await context.read<TripsCubit>().fetchTripDetail(t.id);
      if (!mounted) return;

      // 1) alimente l’overlay (selectedTrip + selectedDay = first)
      context.read<PlanningOverlayCubit>().setTrip(full);

      // 2) ouvre la roue avec le trip complet (days présents)
      setState(() {
        _focusedTrip = full;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      // fallback sans dépendre d'une clé i18n manquante
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Une erreur est survenue.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlanningOverlayCubit, PlanningOverlayState>(
      listenWhen: (prev, next) => prev.selectedTrip != next.selectedTrip,
      listener: (ctx, overlay) {
        final newTrip = overlay.selectedTrip;
        if (_focusedTrip != null && newTrip != null && newTrip.id == _focusedTrip!.id) {
          setState(() {
            _focusedTrip = newTrip; // ✅ met à jour la source de vérité de la roue
          });
        }
      },
      child: BlocBuilder<TripsCubit, TripsState>(
        buildWhen: (p, n) => p.trips != n.trips || p.fetchStatus != n.fetchStatus,
        builder: (ctx, st) {
          if (_loading) {
            return SizedBox(
              height: widget.height,
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          if (_focusedTrip != null) {
            return TripDaysStrip(
              height: widget.height,
              trip: _focusedTrip!,
              onBack: () => setState(() => _focusedTrip = null),
              onCenteredDayChanged: (d) {
                context.read<PlanningOverlayCubit>().selectDay(d);
              },
            );
          }

          return TripCardsStrip(
            height: widget.height,
            trips: st.trips,
            onTripSelected: _onTripSelected,
            onCreateTap: () => _openCreateFlow(context),
            onDeleteTap: (trip) async => context.read<TripsCubit>().delete(trip.id),
            onEditTap: (trip) => _openEditFlow(context, trip),
          );
        },
      ),
    );
  }
}
