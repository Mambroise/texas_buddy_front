//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/trips_strip.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter/material.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/core/l10n/l10n_ext.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/sheets/trip_create_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/features/planning/presentation/cubits/trips_cubit.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/sheets/trip_create_sheet.dart';

class TripsStrip extends StatelessWidget {
  final double height;
  final List<String> trips;

  /// Nouveau: callback avec le brouillon validé
  final ValueChanged<TripDraft>? onCreate;

  /// Ancien: si tu veux garder une compatibilité temporaire
  final VoidCallback? onNewTrip;

  const TripsStrip({
    super.key,
    required this.height,
    required this.trips,
    this.onCreate,
    this.onNewTrip,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> _openCreateSheet() async {
      final draft = await showModalBottomSheet<TripDraft>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        backgroundColor: Colors.white,
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: TripCreateSheet(
            onSubmit: (d) => Navigator.of(ctx).pop(d),
          ),
        ),
      );
      if (draft != null) {
        // Création via Cubit
        context.read<TripsCubit>().create(
          title: draft.title,
          startDate: draft.range.start,
          endDate: draft.range.end,
          adults: draft.adults,
          children: draft.children,
        );
      }
    }

    Widget addButton({double size = 64}) => InkWell(
      onTap: _openCreateSheet,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.texasBlue, width: 1),
          boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x16000000))],
        ),
        child: const Icon(Icons.add, size: 30, color: AppColors.texasBlue),
      ),
    );

    Widget tripCard(String name) => Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.texasBlue, width: 1),
        boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x12000000))],
      ),
      alignment: Alignment.center,
      child: Text(
        name,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.texasBlue),
      ),
    );

    if (trips.isEmpty) {
      return SizedBox(height: height, child: Center(child: addButton()));
    }

    return SizedBox(
      height: height,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final t in trips) ...[
                tripCard(t),
                const SizedBox(width: 12),
              ],
              addButton(size: 56),
            ],
          ),
        ),
      ),
    );
  }
}