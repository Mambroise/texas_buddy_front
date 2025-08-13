//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/data/dtos/nearby_dtos.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';

class NearbyItemDto {
  final String id;
  final String type;                // "activity" | "event"
  final String name;
  final double latitude;
  final double longitude;
  final bool hasPromotion;          // has_promotion
  final bool isAdvertisement;       // is_advertisement
  final double? averageRating;      // average_rating (si dispo)
  final List<String> categories;    // category[].name
  final String? imageUrl;           // image (si dispo)
  final double? distanceKm;         // distance

  NearbyItemDto({
    required this.id,
    required this.type,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.hasPromotion,
    required this.isAdvertisement,
    this.averageRating,
    this.categories = const [],
    this.imageUrl,
    this.distanceKm,
  });

  factory NearbyItemDto.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic v) => v is num ? v.toDouble() : double.parse(v.toString());
    final latRaw = json['latitude'] ?? json['lat'];
    final lonRaw = json['longitude'] ?? json['lng'] ?? json['lon']; // 👈 backend = lng

    // category est une liste d’objets {id, name, icon...}
    final cats = (json['category'] as List?) ?? const [];
    final catNames = cats.map((e) => (e as Map)['name'].toString()).toList();

    return NearbyItemDto(
      id: (json['id'] ?? json['uuid'] ?? json['pk']).toString(),
      type: (json['type'] ?? 'activity').toString(),
      name: (json['name'] ?? '').toString(),
      latitude: parseNum(latRaw),
      longitude: parseNum(lonRaw),
      hasPromotion: (json['has_promotion'] ?? false) as bool,
      isAdvertisement: (json['is_advertisement'] ?? false) as bool,
      averageRating: (json['average_rating']) == null ? null : parseNum(json['average_rating']),
      categories: catNames,
      imageUrl: json['image']?.toString(),
      distanceKm: (json['distance']) == null ? null : parseNum(json['distance']),
    );
  }

  NearbyItem toDomain() {
    final kind = type.toLowerCase() == 'event' ? NearbyKind.event : NearbyKind.activity;
    return NearbyItem(
      id: id,
      kind: kind,
      name: name,
      latitude: latitude,
      longitude: longitude,
      hasPromotion: hasPromotion,
      isAdvertisement: isAdvertisement,
      averageRating: averageRating,
      categories: categories,
      imageUrl: imageUrl,
      distanceKm: distanceKm,
    );
  }
}

