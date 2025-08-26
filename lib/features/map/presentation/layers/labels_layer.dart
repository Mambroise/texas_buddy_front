//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/layers/labels_layer.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/nearby_item.dart';
import '../markers/category_icon_mapper.dart';

/// Gère les "badges label" affichés au-dessus des pins:
/// - rendu bitmap (icône + texte, wrap 2 lignes max)
/// - animation d'ouverture (fade-in du bg+texte), fermeture sèche
/// - toggle au tap (pin OU label)
/// - recalage lors des mouvements caméra
///
/// Usage côté page:
///   final _labels = LabelsLayer(context);
///   _labels.updateForItems(items: items, controller: _controller!, onChanged: _applyLabels);
///   _labels.recalcPositions(items: _lastItems, controller: _controller!, onChanged: _applyLabels);
///   _labels.toggleExpand(it, items: _lastItems, controller: _controller!, onChanged: _applyLabels);
class LabelsLayer {
  LabelsLayer(this._context);

  final BuildContext _context;

  // ── caches / état interne
  final Map<String, BitmapDescriptor> _bmpCache = {};
  final Map<String, double> _widthCache = {};
  final Set<String> _expandedIds = {};
  bool _animBusy = false;

  // ── constantes layout/rendu
  static const double _padH = 8;
  static const double _padV = 6;
  static const double _gap = 6;
  static const double _iconSize = 25;
  static const double _maxTextWidth = 200; // largeur max avant wrap
  static const double _anchorShiftPx = 12; // décale l'ancre vers la droite
  static const int _dyAbovePx = 1;         // hauteur du badge au-dessus du pin

  // ── ids/keys helpers
  String baseIdFor(NearbyItem it) => '${it.kind.name}_${it.id}';
  String labelIdFor(NearbyItem it) => 'label_${it.kind.name}_${it.id}';
  String _cacheKey(NearbyItem it, bool expanded) {
    final theme = WidgetsBinding.instance.platformDispatcher.platformBrightness.name;
    return 'lbl_${it.kind.name}_${it.id}_${expanded ? "x" : "_"}_$theme';
    // NB: on ne met en cache que l’opacité finale (1.0)
  }

  // ── géométrie écran → lat/lng
  Future<LatLng> _latLngAbove(GoogleMapController controller, LatLng base, {int dyPx = _dyAbovePx}) async {
    final sc = await controller.getScreenCoordinate(base);
    final above = ScreenCoordinate(x: sc.x, y: math.max(0, sc.y - dyPx));
    return controller.getLatLng(above);
  }

  // ── rendu d’un bitmap de label (icône + texte optionnel + bg optionnel)
  Future<BitmapDescriptor> _buildLabelBadge(
      NearbyItem it, {
        required bool expanded,
        double opacity = 1.0, // ANIME seulement bg+texte (icône reste opaque)
      }) async {
    final key = _cacheKey(it, expanded);
    // Ne met en cache que l’état final
    if (opacity == 1.0) {
      final cached = _bmpCache[key];
      if (cached != null) return cached;
    }

    final dpr = MediaQuery.of(_context).devicePixelRatio;
    final icon = CategoryIconMapper.map(it.primaryCategory ?? '');
    final name = it.name;

    // Texte max 2 lignes + ellipsis
    final pb = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textDirection: TextDirection.ltr,
        maxLines: expanded ? 2 : 1,
        ellipsis: expanded ? '…' : null,
      ),
    )..pushStyle(ui.TextStyle(
      color: const Color(0xFF000000).withValues(alpha: opacity),
      fontSize: 22,
      fontWeight: ui.FontWeight.w600,
    ))
      ..addText(expanded ? ' $name' : '');
    final paragraph = pb.build()
      ..layout(const ui.ParagraphConstraints(width: _maxTextWidth));

    // Dimensions
    final textW = expanded ? math.min(paragraph.longestLine, _maxTextWidth) : 0.0;
    final textH = expanded ? paragraph.height : 0.0;
    final h = math.max(_iconSize, textH) + _padV * 2;
    final w = (_padH * 2) + _iconSize + (expanded ? _gap + textW : 0);

    // Canvas
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // BG arrondi (seulement en expanded)
    if (expanded) {
      final bgPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.92 * opacity);
      final rrect = RRect.fromLTRBR(0, 0, w, h, const Radius.circular(14));
      canvas.drawRRect(rrect, bgPaint);
    }

    // Icône (toujours 100% visible, pas d’opacité animée)
    final iconTp = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: _iconSize,
          color: Colors.black87,
        ),
      ),
    )..layout();
    iconTp.paint(canvas, Offset(_padH, (h - iconTp.height) / 2));

    // Texte
    if (expanded) {
      final textX = _padH + _iconSize + _gap;
      final textY = (h - textH) / 2;
      canvas.drawParagraph(paragraph, Offset(textX, textY));
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage((w * dpr).ceil(), (h * dpr).ceil());
    final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    final desc = BitmapDescriptor.bytes(bytes);

    if (opacity == 1.0) {
      _bmpCache[key] = desc;
      _widthCache[key] = w;
    }
    return desc;
  }

  // ── largeur (fallback si pas en cache)
  double _estimateWidth(NearbyItem it, bool expanded) {
    if (!expanded) return (_padH * 2) + _iconSize;
    final pb = ui.ParagraphBuilder(
      ui.ParagraphStyle(textDirection: TextDirection.ltr, maxLines: 2, ellipsis: '…'),
    )..pushStyle(ui.TextStyle(fontSize: 22, fontWeight: ui.FontWeight.w600))
      ..addText(' ${it.name}');
    final p = pb.build()..layout(const ui.ParagraphConstraints(width: _maxTextWidth));
    final tw = math.min(p.longestLine, _maxTextWidth);
    return (_padH * 2) + _iconSize + _gap + tw;
  }

  // ── construit un Marker label pour un item (avec onTap → toggle)
  Future<Marker> _buildOneLabelMarker(
      NearbyItem it, {
        required GoogleMapController controller,
        double opacity = 1.0,
        required Future<void> Function(NearbyItem) onToggle, // callback fourni par la page
      }) async {
    final expanded = _expandedIds.contains(baseIdFor(it));
    final cacheKey = _cacheKey(it, expanded);

    final base = LatLng(it.latitude, it.longitude);
    final labelPos = await _latLngAbove(controller, base, dyPx: _dyAbovePx);
    final bmp = await _buildLabelBadge(it, expanded: expanded, opacity: opacity);

    final width = _widthCache[cacheKey] ?? _estimateWidth(it, expanded);

    // ancre centrée sur l’icône, décalée de 12 px vers la droite
    final anchorX = (_padH + _iconSize / 2 - _anchorShiftPx) / width;
    const anchorY = 0.8;

    return Marker(
      markerId: MarkerId(labelIdFor(it)),
      position: labelPos,
      icon: bmp,
      anchor: Offset(anchorX, anchorY),
      consumeTapEvents: true,
      onTap: () => onToggle(it),
    );
  }

  // ── remplit tous les labels pour une liste (appelé au fetch / aux filtres)
  Future<void> updateForItems({
    required List<NearbyItem> items,
    required GoogleMapController controller,
    required void Function(Map<MarkerId, Marker> labels) onBulk,   // full refresh
    required void Function(Map<MarkerId, Marker> labels) onPatch,  // patch
  }) async {
    _expandedIds.retainWhere((id) => items.any((it) => baseIdFor(it) == id));

    final labels = <MarkerId, Marker>{};
    for (final it in items) {
      final m = await _buildOneLabelMarker(
        it,
        controller: controller,
        opacity: 1.0,
        // ⬅️ tap label => PATCH (pas full)
        onToggle: (x) => toggleExpand(
          x,
          items: items,
          controller: controller,
          onPatch: onPatch,
        ),
      );
      labels[m.markerId] = m;
    }
    onBulk(labels); // ⬅️ build initial = FULL
  }

  // ── recalcule la position des labels à la fin d’un pan/zoom
  Future<void> recalcPositions({
    required List<NearbyItem> items,
    required GoogleMapController controller,
    required void Function(Map<MarkerId, Marker> labels) onBulk,   // full
    required void Function(Map<MarkerId, Marker> labels) onPatch,  // patch
  }) async {
    final labels = <MarkerId, Marker>{};
    for (final it in items) {
      final m = await _buildOneLabelMarker(
        it,
        controller: controller,
        opacity: 1.0,
        onToggle: (x) => toggleExpand(
          x,
          items: items,
          controller: controller,
          onPatch: onPatch, // ⬅️ tap = PATCH
        ),
      );
      labels[m.markerId] = m;
    }
    onBulk(labels); // ⬅️ recalc = FULL
  }

  // ── ouvre/ferme un label avec anim (open) / fermeture sèche (close)
  Future<void> toggleExpand(
      NearbyItem it, {
        required List<NearbyItem> items,
        required GoogleMapController controller,
        required void Function(Map<MarkerId, Marker> labels) onPatch,
      }) async {
    if (_animBusy) return;
    _animBusy = true;

    final selId = baseIdFor(it);
    final isOpen = _expandedIds.contains(selId);

    // Fermer ce qui est ouvert (fermeture sèche) → PATCH (peut contenir plusieurs entrées)
    if (!isOpen && _expandedIds.isNotEmpty) {
      final toClose = List<String>.from(_expandedIds);
      _expandedIds.clear();
      final labels = <MarkerId, Marker>{};
      for (final id in toClose) {
        final item = items.firstWhere((x) => baseIdFor(x) == id, orElse: () => it);
        final m = await _buildOneLabelMarker(item, controller: controller, opacity: 1.0,
          onToggle: (x) => toggleExpand(x, items: items, controller: controller, onPatch: onPatch),
        );
        labels[m.markerId] = m;
      }
      onPatch(labels);
    }

    // Ouvrir avec fade-in → PATCH (seulement l’item)
    if (!isOpen) {
      _expandedIds.add(selId);
      const steps = 8;
      for (int i = 1; i <= steps; i++) {
        final t = i / steps;
        final m = await _buildOneLabelMarker(it, controller: controller, opacity: t,
          onToggle: (x) => toggleExpand(x, items: items, controller: controller, onPatch: onPatch),
        );
        onPatch({m.markerId: m});
        await Future.delayed(const Duration(milliseconds: 10));
      }
      _animBusy = false;
      return;
    }

    // Fermer (sèche) → PATCH
    _expandedIds.remove(selId);
    final m = await _buildOneLabelMarker(it, controller: controller, opacity: 1.0,
      onToggle: (x) => toggleExpand(x, items: items, controller: controller, onPatch: onPatch),
    );
    onPatch({m.markerId: m});
    _animBusy = false;
  }
}
