//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/timeline/add_address_button.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:texas_buddy/core/l10n/l10n_ext.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';

class AddAddressButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const AddAddressButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
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
    );
  }
}
