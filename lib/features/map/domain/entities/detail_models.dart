//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/domain/entities/detail_models.dart
// Author : Morice
//---------------------------------------------------------------------------


class CategoryEntity {
  final String id;
  final String name;
  final String? icon;
  final String? description;
  const CategoryEntity({
    required this.id,
    required this.name,
    this.icon,
    this.description,
  });
}

class PromotionEntity {
  final String id;
  final String title;
  final String? description;
  final String discountType; // e.g. percentage / amount
  final num amount;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isActive;
  const PromotionEntity({
    required this.id,
    required this.title,
    this.description,
    required this.discountType,
    required this.amount,
    this.startDate,
    this.endDate,
    this.isActive,
  });
}

// For Activity detail
class ActivityDetailEntity {
  final String id;
  final String name;
  final String? description;
  final List<CategoryEntity> categories;
  final CategoryEntity? primaryCategory;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? placeId;
  final double latitude;
  final double longitude;
  final String? image;
  final String? website;
  final String? phone;
  final String? email;
  final num? price;
  final int? duration; // minutes
  final bool? isByReservation;
  final bool? staffFavorite;
  final bool? isActive;
  final DateTime? createdAt;
  final PromotionEntity? currentPromotion;


  const ActivityDetailEntity({
    required this.id,
    required this.name,
    this.description,
    required this.categories,
    this.primaryCategory,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.placeId,
    required this.latitude,
    required this.longitude,
    this.image,
    this.website,
    this.phone,
    this.email,
    this.price,
    this.duration,
    this.isByReservation,
    this.staffFavorite,
    this.isActive,
    this.createdAt,
    this.currentPromotion,
  });
}

// For Event detail
class EventDetailEntity {
  final String id;
  final String name;
  final String? description;
  final DateTime? start;
  final DateTime? end;
  final String? location;
  final String? city;
  final String? state;
  final String? placeId;
  final double latitude;
  final double longitude;
  final List<CategoryEntity> categories;
  final CategoryEntity? primaryCategory;
  final String? website;
  final String? image;
  final num? price;
  final int? duration; // minutes
  final bool? isByReservation;
  final bool? staffFavorite;
  final bool? isPublic;
  final DateTime? createdAt;
  final List<PromotionEntity> promotions;
  final PromotionEntity? currentPromotion;
  final bool? hasPromotion;


  const EventDetailEntity({
    required this.id,
    required this.name,
    this.description,
    this.start,
    this.end,
    this.location,
    this.city,
    this.state,
    this.placeId,
    required this.latitude,
    required this.longitude,
    required this.categories,
    this.primaryCategory,
    this.website,
    this.image,
    this.price,
    this.duration,
    this.isByReservation,
    this.staffFavorite,
    this.isPublic,
    this.createdAt,
    this.promotions = const [],
    this.currentPromotion,
    this.hasPromotion,
  });
}