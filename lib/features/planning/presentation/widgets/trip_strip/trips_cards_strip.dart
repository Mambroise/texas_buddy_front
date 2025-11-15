//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/trip_strip/trips_cards_strip.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/core/l10n/l10n_ext.dart';
import 'package:texas_buddy/features/planning/domain/entities/trip.dart';

// util / widgets que tu as déjà extraits
import 'package:texas_buddy/core/utils/outside_dismiss_barrier.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/action_icon_button.dart';
import 'package:texas_buddy/features/planning/presentation/widgets/sheets/confirm_action_sheet.dart';


class TripCardsStrip extends StatefulWidget {
  final double height;
  final List<Trip> trips;

  /// Tap court : sélectionner un voyage (pour afficher la roue de jours)
  final ValueChanged<Trip> onTripSelected;

  /// Bouton “+”
  final VoidCallback onCreateTap;

  /// Suppression (retourne true si ok côté domaine)
  final Future<bool> Function(Trip trip) onDeleteTap;

  /// Edition (ouvre ton sheet d’édition, ou autre)
  final ValueChanged<Trip> onEditTap;

  const TripCardsStrip({
    super.key,
    required this.height,
    required this.trips,
    required this.onTripSelected,
    required this.onCreateTap,
    required this.onDeleteTap,
    required this.onEditTap,
  });

  @override
  State<TripCardsStrip> createState() => _TripCardsStripState();
}

class _TripCardsStripState extends State<TripCardsStrip> {
  int? _actionTripId;

  // barrière “tap à l’extérieur pour fermer”
  final GlobalKey _hostKey = GlobalKey();
  late final OutsideDismissBarrier _outsideBarrier;

  @override
  void initState() {
    super.initState();
    _outsideBarrier = OutsideDismissBarrier(hostKey: _hostKey, onDismiss: _closeActions);
  }

  @override
  void dispose() {
    _outsideBarrier.hide();
    super.dispose();
  }

  void _openActions(int id) {
    setState(() => _actionTripId = id);
    _outsideBarrier.show(context);
  }

  void _closeActions() {
    if (_actionTripId != null) setState(() => _actionTripId = null);
    _outsideBarrier.hide();
  }

  Widget _addButton({double size = 64}) => InkWell(
    onTap: widget.onCreateTap,
    borderRadius: BorderRadius.circular(size / 2),
    child: Tooltip(
      message: context.l10n.trips_add_label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.fog,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.texasBlue, width: 1),
          boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x16000000))],
        ),
        child: const Icon(Icons.add, size: 30, color: AppColors.texasBlue),
      ),
    ),
  );

  Widget _flagPlaceholder() => Container(
    width: 54,
    height: 36,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: AppColors.texasBlue, width: 1),
      boxShadow: const [BoxShadow(blurRadius: 6, offset: Offset(0, 2), color: Color(0x12000000))],
    ),
    child: const Icon(Icons.flag, size: 18, color: AppColors.texasBlue),
  );

  String _dateRange(BuildContext context, Trip t) {
    final ml = MaterialLocalizations.of(context);
    return '${ml.formatShortMonthDay(t.startDate)} – ${ml.formatShortMonthDay(t.endDate)}';
  }



  Widget _tripCard(Trip t) => Container(
    width: 160,
    height: 120,
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.texasBlue, width: 1),
      boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x12000000))],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          t.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.texasBlue),
        ),
        const SizedBox(height: 8),
        _flagPlaceholder(),
        const SizedBox(height: 8),
        Text(
          _dateRange(context, t),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );

  Widget _tripItem(Trip t) {
    final isActionOpen = _actionTripId == t.id;

    return GestureDetector(
      onTap: () {
        if (isActionOpen) {
          _closeActions();
        } else {
          widget.onTripSelected(t);
        }
      },
      onLongPress: () => _openActions(t.id),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _tripCard(t),
          // Actions à droite
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            right: isActionOpen ? -6 : -48,
            top: -8,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: isActionOpen ? 1 : 0,
              child: Column(
                children: [
                  ActionIconButton(
                    icon: Icons.delete,
                    bg: Colors.red.shade50,
                    fg: Colors.red.shade700,
                    tooltip: context.l10n.trips_actions_delete_tooltip,
                    onTap: () async {
                      // IMPORTANT : fermer la barrière avant d’ouvrir le bottom sheet
                      _outsideBarrier.pause();
                      final ok = await showConfirmActionSheet(
                        context,
                        title: context.l10n.trips_delete_title,
                        message: context.l10n.trips_delete_message(t.title),
                        cancelLabel: context.l10n.common_cancel,
                        confirmLabel: context.l10n.trips_delete_confirm,
                        icon: Icons.warning_amber_rounded,
                        confirmBg: Colors.red.shade50,
                        confirmFg: Colors.red.shade800,
                      );
                      _outsideBarrier.resume();


                      if (ok == true && mounted) {
                        final success = await widget.onDeleteTap(t);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success ? context.l10n.trips_delete_success : context.l10n.trips_delete_error,
                            ),
                          ),
                        );
                        _closeActions();
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
                      widget.onEditTap(t);
                      _closeActions();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.trips;

    if (items.isEmpty) {
      return Center(child: _addButton());
    }

    return SizedBox(
      key: _hostKey,
      height: widget.height,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final t in items) ...[
                _tripItem(t),
                const SizedBox(width: 12),
              ],
              _addButton(size: 56),
            ],
          ),
        ),
      ),
    );
  }
}
