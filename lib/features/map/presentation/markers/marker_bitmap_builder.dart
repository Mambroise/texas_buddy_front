//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/markers/marker_bitmap_builder.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'marker_style.dart';

class MarkerBitmapBuilder {
  final double pixelRatio;
  final _cache = <String, BitmapDescriptor>{};

  MarkerBitmapBuilder({required this.pixelRatio});

  String _key({
    required String categoryKey,
    required double? rating,
    required Color borderColor,
    required Color fillColor,
    required double boxWidth,
    required double borderWidth,
  }) =>
      '${categoryKey}_${(rating ?? -1).toStringAsFixed(1)}_${borderColor.value}_${fillColor.value}_w${boxWidth}_bw${borderWidth}_$pixelRatio';

  Future<BitmapDescriptor> build({
    required IconData categoryIcon,
    required double? averageRating,
    required MarkerStyle style,
    String categoryKey = 'default',
  }) async {
    final k = _key(
      categoryKey: categoryKey,
      rating: averageRating,
      borderColor: style.borderColor,
      fillColor: style.fillColor,
      boxWidth: style.boxWidth,
      borderWidth: style.borderWidth,
    );
    final cached = _cache[k];
    if (cached != null) return cached;

    // --- dimensions : plus de "pointe" => hauteur = boxHeight ---
    final width = style.boxWidth;
    final height = style.boxHeight;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(pixelRatio, pixelRatio);

    // --- fond + bord : RRect avec angle bas-gauche SANS rayon ---
    final boxRect = Rect.fromLTWH(0, 0, width, style.boxHeight);
    final r = Radius.circular(style.borderRadius);
    final rrect = RRect.fromRectAndCorners(
      boxRect,
      topLeft: r,
      topRight: r,
      bottomRight: r,
      bottomLeft: Radius.zero, // 👈 angle vif = “pointe”
    );

    final fillPaint = Paint()..color = style.fillColor;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.borderWidth
      ..color = style.borderColor;

    canvas.drawRRect(rrect, fillPaint);
    canvas.drawRRect(rrect, borderPaint);

    // --- contenu (icône + éventuelle note) ---
    const pad = 8.0;
    final iconSize = style.boxHeight * 0.6;

    // catégorie
    final iconTp = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(categoryIcon.codePoint),
        style: TextStyle(
          fontFamily: categoryIcon.fontFamily,
          package: categoryIcon.fontPackage,
          fontSize: iconSize,
          color: style.iconColor,
        ),
      ),
    )..layout();
    iconTp.paint(canvas, Offset(pad, (style.boxHeight - iconTp.height) / 2));

    // rating (optionnel)
    if (averageRating != null) {
      final ratingStr = averageRating.toStringAsFixed(1);
      final star = Icons.star;

      final starTp = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: String.fromCharCode(star.codePoint),
          style: TextStyle(
            fontFamily: star.fontFamily,
            package: star.fontPackage,
            fontSize: 14,
            color: style.ratingStarColor,
          ),
        ),
      )..layout();

      final textTp = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: ' $ratingStr',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: style.ratingTextColor,
          ),
        ),
      )..layout();

      final pillW = starTp.width + textTp.width + 10;
      const pillH = 20.0;
      final pillRect = RRect.fromLTRBR(
        width - pad - pillW,
        (style.boxHeight - pillH) / 2,
        width - pad,
        (style.boxHeight + pillH) / 2,
        const Radius.circular(10),
      );

      final pillPaint = Paint()..color = style.ratingPillColor;
      canvas.drawRRect(pillRect, pillPaint);
      canvas.drawRRect(pillRect, borderPaint..strokeWidth = 1);

      starTp.paint(canvas, Offset(pillRect.left + 6, pillRect.top + (pillH - starTp.height) / 2));
      textTp.paint(canvas, Offset(pillRect.left + 6 + starTp.width, pillRect.top + (pillH - textTp.height) / 2));
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      (width * pixelRatio).ceil(),
      (height * pixelRatio).ceil(),
    );
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final descriptor = BitmapDescriptor.fromBytes(bytes);
    _cache[k] = descriptor;
    return descriptor;
  }
}
