//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : core/l10n/current_locale.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter/foundation.dart';
import 'dart:ui' show Locale;

/// Contient la langue courante sous forme "fr", "en", "es", etc.
class CurrentLocale extends ValueNotifier<String> {
  CurrentLocale(String initial) : super(initial);

  /// Helper pour la forcer depuis une Locale (prend seulement le code langue)
  void setFromLocale(Locale locale) {
    value = locale.languageCode.toLowerCase();
  }
}
