
//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/widgets/texas_buddy_loader.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:flutter/material.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';

class TexasBuddyLoader extends StatelessWidget {
  final String message;

  const TexasBuddyLoader({super.key, this.message = "Loading..."});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // loader animé
          const CircularProgressIndicator(
            color: AppColors.texasBlue,
            strokeWidth: 4,
          ),
          const SizedBox(height: 20),
          Text(
            message,
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
