//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/trip_create_sheet.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/core/l10n/l10n_ext.dart';

class TripDraft {
  final String title;
  final DateTimeRange range;
  final int adults;
  final int children;

  TripDraft({
    required this.title,
    required this.range,
    required this.adults,
    required this.children,
  });
}

class TripCreateSheet extends StatefulWidget {
  final ValueChanged<TripDraft> onSubmit;

  const TripCreateSheet({super.key, required this.onSubmit});

  @override
  State<TripCreateSheet> createState() => _TripCreateSheetState();
}

class _TripCreateSheetState extends State<TripCreateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtl = TextEditingController();
  DateTimeRange? _range;
  bool _submitting = false;
  int _adults = 2;
  int _children = 0;

  @override
  void dispose() {
    _titleCtl.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1, 1, 1),
      lastDate:  DateTime(now.year + 3, 12, 31),
      initialDateRange: _range,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: context.l10n.tripCreateDatesLabel,
      cancelText: context.l10n.tripCreateCancel,
      confirmText: context.l10n.tripCreateSave,
    );
    if (range != null) setState(() => _range = range);
  }

  String _fmt(DateTime d) => MaterialLocalizations.of(context).formatMediumDate(d);

  Future<void> _submit() async {
    if (_submitting) return;
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;
    if (_range == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.tripCreateValidationDatesRequired)),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      widget.onSubmit(TripDraft(
        title: _titleCtl.text.trim(),
        range: _range!,
        adults: _adults,
        children: _children,
      ));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.black12, borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(l10n.tripCreateTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleCtl,
                    maxLength: 30,
                    decoration: InputDecoration(
                      labelText: l10n.tripCreateNameLabel,
                      hintText:  l10n.tripCreateNameHint,
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: const OutlineInputBorder(),
                      counterText: '',
                    ),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return l10n.tripCreateValidationNameRequired;
                      if (t.length > 30) return l10n.tripCreateValidationNameMax('30');
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.tripCreateDatesLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickRange,
                          icon: const Icon(Icons.event),
                          label: Text(l10n.tripCreateDatesPick),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_range != null) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _DateChip(text: _fmt(_range!.start)),
                        const Icon(Icons.arrow_forward, size: 16, color: Colors.black54),
                        _DateChip(text: _fmt(_range!.end)),
                      ],
                    ),
                  ],


                  const SizedBox(height: 16),

                  // ── ADULTES / ENFANTS (sur la même ligne) ──────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _CounterField(
                          label: l10n.tripCreateAdults,
                          value: _adults,
                          onChanged: (v) => setState(() => _adults = v.clamp(0, 20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CounterField(
                          label: l10n.tripCreateChildren,
                          value: _children,
                          onChanged: (v) => setState(() => _children = v.clamp(0, 20)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.tripCreateCancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(backgroundColor: AppColors.texasBlue),
                          child: _submitting
                              ? const SizedBox(
                            height: 18, width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                              : Text(l10n.tripCreateCreate),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String text;
  const _DateChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.texasBlue, width: 1),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

//INCREMENTEUR POUR ADULTE ET ENFANT
class _CounterField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _CounterField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.texasBlue, width: 1),
        boxShadow: const [
          BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x12000000)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          IconButton(
            onPressed: () => onChanged((value - 1).clamp(0, 20)),
            icon: const Icon(Icons.remove),
            tooltip: '-',
          ),
          Text('$value', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          IconButton(
            onPressed: () => onChanged((value + 1).clamp(0, 20)),
            icon: const Icon(Icons.add),
            tooltip: '+',
          ),
        ],
      ),
    );
  }
}

