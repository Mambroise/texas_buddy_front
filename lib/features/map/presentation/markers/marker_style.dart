//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/markers/marker_style.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter/material.dart';

class MarkerStyle {
  final double boxWidth;        // largeur du cartouche
  final double boxHeight;       // hauteur du cartouche (hors pointe)
  final double borderRadius;
  final double borderWidth;
  final double tailWidth;       // largeur de la pointe
  final double tailHeight;      // hauteur de la pointe
  final Color fillColor;
  final Color borderColor;
  final Color iconColor;
  final Color ratingTextColor;
  final Color ratingStarColor;
  final Color ratingPillColor;  // fond de la pilule "note"

  const MarkerStyle({
    this.boxWidth = 148,
    this.boxHeight = 48,
    this.borderRadius = 12,
    this.borderWidth = 2,
    this.tailWidth = 18,
    this.tailHeight = 14,
    this.fillColor = const Color(0xFFFFFFFF),
    this.borderColor = const Color(0xFF0A66C2), // AppColors.texasBlue-like
    this.iconColor = const Color(0xFF222222),
    this.ratingTextColor = const Color(0xFF222222),
    this.ratingStarColor = const Color(0xFFFFC107),
    this.ratingPillColor = const Color(0xFFF5F5F5),
  });

  MarkerStyle promoted() => copyWith(
    borderColor: const Color(0xFFFF9900), // accent pub
  );

  MarkerStyle forEvent() => copyWith(
    borderColor: const Color(0xFF8E24AA),
  );

  MarkerStyle copyWith({
    double? boxWidth,
    double? boxHeight,
    double? borderRadius,
    double? borderWidth,
    double? tailWidth,
    double? tailHeight,
    Color? fillColor,
    Color? borderColor,
    Color? iconColor,
    Color? ratingTextColor,
    Color? ratingStarColor,
    Color? ratingPillColor,
  }) {
    return MarkerStyle(
      boxWidth: boxWidth ?? this.boxWidth,
      boxHeight: boxHeight ?? this.boxHeight,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      tailWidth: tailWidth ?? this.tailWidth,
      tailHeight: tailHeight ?? this.tailHeight,
      fillColor: fillColor ?? this.fillColor,
      borderColor: borderColor ?? this.borderColor,
      iconColor: iconColor ?? this.iconColor,
      ratingTextColor: ratingTextColor ?? this.ratingTextColor,
      ratingStarColor: ratingStarColor ?? this.ratingStarColor,
      ratingPillColor: ratingPillColor ?? this.ratingPillColor,
    );
  }
}
