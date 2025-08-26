//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/domain/entities/nearby_item.dart
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
  final bool isAdvertisement;
  final double? averageRating;
  final String? primaryCategory;
  final List<String> categories;
  final String? imageUrl;
  final double? distanceKm;
  final DateTime? startDateTime;
  final DateTime? endDateTime;

  const NearbyItem({
    required this.id,
    required this.kind,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.hasPromotion,
    this.isAdvertisement = false,
    this.averageRating,
    this.primaryCategory,
    this.categories = const [],
    this.imageUrl,
    this.distanceKm,
    this.startDateTime,
    this.endDateTime,
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
    String? primaryCategory,
    List<String>? categories,
    String? imageUrl,
    double? distanceKm,
    DateTime? startDateTime,
    DateTime? endDateTime,
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
      primaryCategory: primaryCategory ?? this.primaryCategory,
      categories: categories ?? this.categories,
      imageUrl: imageUrl ?? this.imageUrl,
      distanceKm: distanceKm ?? this.distanceKm,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
    );
  }
}
