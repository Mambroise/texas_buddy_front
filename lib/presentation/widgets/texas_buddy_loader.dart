//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : presentation/widgets/texas_buddy_loader.dart
// Author : Morice
//-------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';

// L10n
import 'package:texas_buddy/core/l10n/l10n_ext.dart';

class TexasBuddyLoader extends StatelessWidget {
  final String? message;

  const TexasBuddyLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = message ?? l10n.loading;

    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // loader animé
          CircularProgressIndicator(
            color: AppColors.texasBlue,
            strokeWidth: 4,
            semanticsLabel: l10n.loading,
          ),
          const SizedBox(height: 20),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.texasBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
