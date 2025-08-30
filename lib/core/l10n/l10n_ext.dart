//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : core/l10n/l10n_ext.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter/widgets.dart';
import 'package:texas_buddy/core/l10n/generated/l10n.dart';


extension I18nX on BuildContext {
  L10n get l10n => L10n.of(this)!;
}
