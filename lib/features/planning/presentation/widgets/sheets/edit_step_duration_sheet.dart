//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/sheets/edit_step_duration_sheet.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/core/l10n/l10n_ext.dart';

class EditStepDurationSheet extends StatefulWidget {
  final String title;
  final int initialDurationMinutes;

  const EditStepDurationSheet({
    super.key,
    required this.title,
    required this.initialDurationMinutes,
  });

  @override
  State<EditStepDurationSheet> createState() => _EditStepDurationSheetState();
}

class _EditStepDurationSheetState extends State<EditStepDurationSheet> {
  late int _hours;
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _hours = widget.initialDurationMinutes ~/ 60;
    _minutes = widget.initialDurationMinutes % 60;

    // on force des paliers de 5 min pour les minutes
    _minutes = (_minutes / 5).round() * 5;
  }

  int get _totalMinutes => _hours * 60 + _minutes;

  void _onValidate() {
    if (_totalMinutes <= 0) {
      // on évite les durées nulles ou négatives
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.genericError)),
      );
      return;
    }
    Navigator.of(context).pop<int>(_totalMinutes);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        // même esprit que ConfirmActionSheet, mais on garde le viewInsets
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),

            // 👇 Icône en header (comme l’icône warning du delete)
            Icon(
              Icons.schedule,
              size: 28,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 6),

            // Titre centré, même style que ConfirmActionSheet
            Text(
              l10n.timeline_edit_duration_title(widget.title),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            // Sous-titre centré & gris
            Text(
              l10n.timeline_edit_duration_subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            // Sélecteurs de durée
            Row(
              children: [
                Expanded(
                  child: _DurationSegment(
                    label: l10n.common_hours_short, // ex: "h"
                    value: _hours,
                    min: 0,
                    max: 12,
                    onChanged: (v) => setState(() => _hours = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DurationSegment(
                    label: l10n.common_minutes_short, // ex: "min"
                    value: _minutes,
                    min: 0,
                    max: 55,
                    step: 5,
                    onChanged: (v) => setState(() => _minutes = v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Ligne de boutons comme dans ConfirmActionSheet
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.common_cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.texasBlue.withOpacity(0.12),
                      foregroundColor: AppColors.texasBlue,
                    ),
                    onPressed: _onValidate,
                    child: Text(l10n.common_save),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}


class _DurationSegment extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  const _DurationSegment({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.step = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = <int>[];
    for (int v = min; v <= max; v += step) {
      options.add(v);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          DropdownButton<int>(
            value: value,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(12),
            items: options
                .map(
                  (v) => DropdownMenuItem(
                value: v,
                child: Text(v.toString().padLeft(2, '0')),
              ),
            )
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
