

import 'package:flutter/material.dart';

/// Barrière cliquable partout en dehors du widget référencé par [hostKey].
/// - `show()` : insère une overlay avec 4 zones cliquables autour de la zone hôte.
/// - `hide()` : retire l'overlay.
/// - `pause()` / `resume()` : désactive / réactive temporairement la capture des taps
///   (utile pendant l’ouverture d’un bottom sheet / dialog).
/// - `refresh()` : recalcule la zone hôte si sa position/dimension a changé.
class OutsideDismissBarrier {
  OutsideDismissBarrier({
    required this.hostKey,
    required this.onDismiss,
  });

  final GlobalKey hostKey;
  final VoidCallback onDismiss;

  OverlayEntry? _entry;
  Rect? _hostRect;
  bool _paused = false;

  bool get isShown => _entry != null;

  void show(BuildContext context) {
    if (_entry != null) return; // déjà affichée
    _computeHostRect();
    final overlay = Overlay.of(context, rootOverlay: true);
    if (overlay == null || _hostRect == null) return;

    _entry = OverlayEntry(
      builder: (_) {
        // En pause => on ne capture rien (taps passent au-dessous).
        return IgnorePointer(
          ignoring: _paused,
          child: _BarrierLayer(
            rect: _hostRect!,
            onDismiss: onDismiss,
          ),
        );
      },
    );
    overlay.insert(_entry!);
  }

  void hide() {
    _entry?..remove();
    _entry = null;
    _hostRect = null;
    _paused = false;
  }

  /// Désactive temporairement la capture des taps.
  void pause() {
    if (!_paused) {
      _paused = true;
      _entry?.markNeedsBuild();
    }
  }

  /// Réactive la capture des taps.
  void resume() {
    if (_paused) {
      _paused = false;
      _entry?.markNeedsBuild();
    }
  }

  /// Recalcule la zone de l’hôte (si scroll/layout a bougé).
  void refresh() {
    _computeHostRect();
    _entry?.markNeedsBuild();
  }

  void _computeHostRect() {
    final ctx = hostKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final topLeft = box.localToGlobal(Offset.zero);
    _hostRect = topLeft & box.size;
  }
}

class _BarrierLayer extends StatelessWidget {
  const _BarrierLayer({required this.rect, required this.onDismiss});
  final Rect rect;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 4 zones cliquables autour de la zone host (le “trou”)
        Positioned(
          left: 0, right: 0, top: 0, height: rect.top,
          child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onDismiss),
        ),
        Positioned(
          left: 0, right: 0, top: rect.bottom, bottom: 0,
          child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onDismiss),
        ),
        Positioned(
          left: 0, top: rect.top, width: rect.left, height: rect.height,
          child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onDismiss),
        ),
        Positioned(
          left: rect.right, right: 0, top: rect.top, height: rect.height,
          child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onDismiss),
        ),
      ],
    );
  }
}
