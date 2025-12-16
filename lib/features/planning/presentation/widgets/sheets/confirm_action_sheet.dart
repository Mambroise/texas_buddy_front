//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/sheets/confirm_action_sheet.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';

/// Bottom sheet de confirmation générique.
/// Retourne `true` si confirmé, `false` si annulé, `null` si sheet fermée.
class ConfirmActionSheet extends StatelessWidget {
  const ConfirmActionSheet({
    super.key,
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    this.icon,
    this.confirmBg,
    this.confirmFg,
    this.extra,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;

  /// Icône optionnelle en header (ex: warning)
  final IconData? icon;

  /// Couleurs du bouton "Confirmer" (ex: rouge pour delete)
  final Color? confirmBg;
  final Color? confirmFg;

  /// Widget optionnel en bas (ex: checkbox, note, etc.)
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          if (icon != null) ...[
            Icon(icon, size: 28, color: theme.colorScheme.primary),
            const SizedBox(height: 6),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          if (extra != null) ...[
            const SizedBox(height: 12),
            extra!,
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(cancelLabel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    backgroundColor: confirmBg,
                    foregroundColor: confirmFg,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Helper pratique pour afficher la sheet.
/// Exemple d’appel :
/// final ok = await showConfirmActionSheet(context, title: ..., message: ...);
Future<bool?> showConfirmActionSheet(
    BuildContext context, {
      required String title,
      required String message,
      required String cancelLabel,
      required String confirmLabel,
      IconData? icon,
      Color? confirmBg,
      Color? confirmFg,
      Widget? extra,
    }) {
  return showModalBottomSheet<bool>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (_) => ConfirmActionSheet(
      title: title,
      message: message,
      cancelLabel: cancelLabel,
      confirmLabel: confirmLabel,
      icon: icon,
      confirmBg: confirmBg,
      confirmFg: confirmFg,
      extra: extra,
    ),
  );
}
