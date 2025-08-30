//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/theme/app_colors.dart
// Author : Morice
//-------------------------------------------------------------------------

import 'package:flutter/material.dart';

class AppColors {
  static const Color texasBlue = Color(0xFF002868); // Bleu du drapeau texan
  static const Color texasRed = Color(0xFFBF0A30);
  static const Color texasRedGlow = Color(0xE6BF0A30); // ~90% d'opacité
  static const Color white = Colors.white;
  static const Color transparentWhite = Color.fromRGBO(255, 255, 255, 0.8);

  // ---- Neutres doux (beiges / sables) ------------------------------------
  static const Color beige = Color(0xFFF5F5DC);      // #F5F5DC
  static const Color sand = Color(0xFFE5D5B3);       // #E5D5B3
  static const Color desertSand = Color(0xFFEDC9AF); // #EDC9AF
  static const Color linen = Color(0xFFFAF0E6);      // #FAF0E6
  static const Color almond = Color(0xFFEED9C4);     // #EED9C4

  // ---- Variantes translucides utiles pour overlays -----------------------
  static const Color beigeGlow = Color(0xCCF5F5DC);      // ~80%
  static const Color sandGlow = Color(0xCCE5D5B3);       // ~80%
  static const Color desertSandGlow = Color(0xCCEDC9AF); // ~80%
  static const Color linenGlow = Color(0xE6FAF0E6);      // 90%
  static const Color almondGlow = Color(0xCCEED9C4);     // ~80%

  // ---- Neutres gris clair -------------------------------------------------
  /// Gris très clair et neutre (proche "whitesmoke")
  static const Color lightGray = Color(0xFFF5F5F5);     // #F5F5F5
  /// Gris clair légèrement bleuté (Material BlueGrey 50)
  static const Color fog = Color(0xFFECEFF1);           // #ECEFF1
  /// Gris clair neutre moderne
  static const Color cloud = Color(0xFFF2F4F7);         // #F2F4F7
  /// Gris "platinum" (un poil plus soutenu)
  static const Color platinum = Color(0xFFE5E4E2);      // #E5E4E2

  // ---- Variantes Glow 90% (AA = E6) --------------------------------------
  static const Color lightGrayGlow = Color(0xE6F5F5F5); // 90%
  static const Color fogGlow = Color(0xE6ECEFF1);       // 90%
  static const Color cloudGlow = Color(0xE6F2F4F7);     // 90%
  static const Color platinumGlow = Color(0xE6E5E4E2);  // 90%
}
