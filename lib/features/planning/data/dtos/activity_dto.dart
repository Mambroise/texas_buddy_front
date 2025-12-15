//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/dtos/activity_dto.dart
// Author : Morice
//-------------------------------------------------------------------------

import 'package:texas_buddy/features/planning/data/dtos/category_dto.dart';

/// Data Transfer Object for activity data
class ActivityDto {
  final int id;
  final String name;
  final String placeId;
  final double latitude;
  final double longitude;
  final List<CategoryDto> categories;
  final bool staffFavorite;
  final double? price;
  final bool hasPromotion;
  final double distance;

  /// ✅ Durée en minutes (si renvoyée par le backend)
  final int? durationMinutes;

  ActivityDto({
    required this.id,
    required this.name,
    required this.placeId,
    required this.latitude,
    required this.longitude,
    required this.categories,
    required this.staffFavorite,
    this.price,
    required this.hasPromotion,
    required this.distance,
    this.durationMinutes,
  });

  static int? _parseNullableInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static int? _extractDurationMinutes(Map<String, dynamic> json) {
    // Supporte plusieurs noms possibles pour éviter de casser si le serializer varie
    return _parseNullableInt(
      json['duration_minutes'] ??
          json['duration'] ??
          json['estimated_duration_minutes'],
    );
  }

  /// Creates an [ActivityDto] from a JSON map
  factory ActivityDto.fromJson(Map<String, dynamic> json) {
    return ActivityDto(
      id: json['id'] as int,
      name: json['name'] as String,
      placeId: json['place_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      categories: (json['category'] as List)
          .map((c) => CategoryDto.fromJson(c as Map<String, dynamic>))
          .toList(),
      staffFavorite: json['staff_favorite'] as bool,
      price: (json['price'] as num?)?.toDouble(),
      hasPromotion: json['has_promotion'] as bool,
      distance: (json['distance'] as num).toDouble(),

      // ✅ new
      durationMinutes: _extractDurationMinutes(json),
    );
  }

  /// Converts this [ActivityDto] to a JSON map
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'place_id': placeId,
      'latitude': latitude,
      'longitude': longitude,
      'category': categories.map((c) => c.toJson()).toList(),
      'staff_favorite': staffFavorite,
      'price': price,
      'has_promotion': hasPromotion,
      'distance': distance,

      // ✅ new (optionnel)
      'duration_minutes': durationMinutes,
    };
  }
}
