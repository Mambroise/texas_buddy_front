//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/timeline/no_glow_scroll.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/widgets.dart';

class NoGlowScroll extends ScrollBehavior {
  const NoGlowScroll();
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}
