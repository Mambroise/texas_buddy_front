//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/timeline/timeline_auto_scroller.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/widgets.dart';

class TimelineAutoScroller {
  final ScrollController controller;
  final double Function() viewportHeight;   // ex: () => widget.height
  final double? Function() hoverY;          // ex: () => _hoverY
  final VoidCallback onTick;                // ex: () { if (mounted) setState(() {}); }
  final double edge;
  final double maxSpeed;

  Timer? _timer;

  TimelineAutoScroller({
    required this.controller,
    required this.viewportHeight,
    required this.hoverY,
    required this.onTick,
    this.edge = 80.0,
    this.maxSpeed = 900.0,
  });

  void dispose() => stop();

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void update() {
    if (!controller.hasClients) { stop(); return; }
    final hy = hoverY();
    if (hy == null) { stop(); return; }

    final viewportY = hy - controller.offset;
    final h = viewportHeight();
    final nearTop = viewportY < edge;
    final nearBottom = (h - viewportY) < edge;

    if (!(nearTop || nearBottom)) { stop(); return; }
    _start();
  }

  void _start() {
    _timer ??= Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!controller.hasClients) { stop(); return; }
      final hy = hoverY();
      if (hy == null) { stop(); return; }

      final vY = hy - controller.offset;
      final h = viewportHeight();

      double dyPerSec = 0.0;
      if (vY < edge) {
        final t = (edge - vY).clamp(0.0, edge) / edge;
        dyPerSec = -maxSpeed * t;
      } else if (h - vY < edge) {
        final t = (edge - (h - vY)).clamp(0.0, edge) / edge;
        dyPerSec =  maxSpeed * t;
      }

      if (dyPerSec == 0.0) { stop(); return; }

      final dy = dyPerSec * (16 / 1000);
      final pos = controller.position;
      final target = (pos.pixels + dy).clamp(0.0, pos.maxScrollExtent);
      controller.jumpTo(target);
      onTick();
    });
  }
}
