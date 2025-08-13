//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/domain/entities/user_position.dart
// Author : Morice
//---------------------------------------------------------------------------


enum NearbyKind { activity, event }

class NearbyItem {
  final String id;
  final NearbyKind kind;
  final String name;
  final double latitude;
  final double longitude;
  final bool hasPromotion;
  final bool isAdvertisement;   // 👈 NEW (ads en tête)
  final double? averageRating;
  final List<String> categories;
  final String? imageUrl;
  final double? distanceKm;

  const NearbyItem({
    required this.id,
    required this.kind,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.hasPromotion,
    this.isAdvertisement = false,
    this.averageRating,
    this.categories = const [],
    this.imageUrl,
    this.distanceKm,
  });

  NearbyItem copyWith({
    String? id,
    NearbyKind? kind,
    String? name,
    double? latitude,
    double? longitude,
    bool? hasPromotion,
    bool? isAdvertisement,
    double? averageRating,
    List<String>? categories,
    String? imageUrl,
    double? distanceKm,
  }) {
    return NearbyItem(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      hasPromotion: hasPromotion ?? this.hasPromotion,
      isAdvertisement: isAdvertisement ?? this.isAdvertisement,
      averageRating: averageRating ?? this.averageRating,
      categories: categories ?? this.categories,
      imageUrl: imageUrl ?? this.imageUrl,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}
