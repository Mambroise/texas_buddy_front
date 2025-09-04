//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/data/dtos/detail_dtos.dart
// Author : Morice
//---------------------------------------------------------------------------


import '../../domain/entities/detail_models.dart';

//----HELPER----------------------
int? _toMinutes(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;

    // "HH:MM" ou "HH:MM:SS"
    if (s.contains(':')) {
      final parts = s.split(':');
      int h = 0, m = 0, sec = 0;
      if (parts.length >= 2) {
        h = int.tryParse(parts[0]) ?? 0;
        m = int.tryParse(parts[1]) ?? 0;
        if (parts.length >= 3) {
          sec = int.tryParse(parts[2]) ?? 0;
        }
      } else {
        // format inattendu: tente parse entier
        return int.tryParse(s);
      }
      // total minutes (arrondi sec → min)
      final totalMin = h * 60 + m + ((sec >= 30) ? 1 : 0);
      return totalMin;
    }

    // Nombre sous forme de chaîne -> minutes
    return int.tryParse(s);
  }
  return null;
}


class CategoryDto {
  final String id;
  final String name;
  final String? icon;
  final String? description;
  CategoryDto({
    required this.id,
    required this.name,
    this.icon,
    this.description});

  factory CategoryDto.fromJson(Map<String,dynamic> j)=>CategoryDto(
    id: j['id'].toString(),
    name: j['name']??'',
    icon: j['icon'],
    description: j['description'],
  );
  CategoryEntity toEntity()=>CategoryEntity(
      id:id,
      name:name,
      icon:icon,
      description:description);
}

class PromotionDto {
  final String id;
  final String title;
  final String? description;
  final String discountType;
  final num amount;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isActive;
  PromotionDto({
    required this.id,
    required this.title,
    this.description,
    required this.discountType,
    required this.amount,
    this.startDate,
    this.endDate,
    this.isActive,
  });

  factory PromotionDto.fromJson(Map<String,dynamic> j)=>PromotionDto(
    id: (j['id']??'').toString(), title: j['title']??'', description: j['description'],
    discountType: j['discount_type']??'', amount: j['amount']??0,
    startDate: j['start_date']!=null?DateTime.tryParse(j['start_date']):null,
    endDate: j['end_date']!=null?DateTime.tryParse(j['end_date']):null,
    isActive: j['is_active'],
  );

  PromotionEntity toEntity()=>PromotionEntity(
    id:id,
    title:title,
    description:description,
    discountType:discountType,
    amount:amount,
    startDate:startDate,
    endDate:endDate,
    isActive:isActive,
  );
}

class ActivityDetailDto {
  final String id;
  final String name;
  final String? description;
  final List<CategoryDto> categories;
  final CategoryDto? primaryCategory;
  final String? address,city,state,zipCode,placeId;
  final double latitude, longitude;
  final String? image,website,phone,email;
  final num? price;
  final int? duration;
  final bool? isByReservation;
  final bool? staffFavorite,isActive;
  final DateTime? createdAt;
  final PromotionDto? currentPromotion;

  ActivityDetailDto({
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

  factory ActivityDetailDto.fromJson(Map<String,dynamic> j){
    List<CategoryDto> cats = (j['category'] as List? ?? []).map((e)=>CategoryDto.fromJson(e)).toList();
    return ActivityDetailDto(
      id: j['id'].toString(),
      name: j['name']??'',
      description: j['description'],
      categories: cats,
      primaryCategory: j['primary_category']!=null?CategoryDto.fromJson(j['primary_category']):null,
      address:j['address'],
      city:j['city'],
      state:j['state'],
      zipCode:j['zip_code'],
      placeId:j['place_id'],
      latitude: (j['latitude'] as num).toDouble(),
      longitude: (j['longitude'] as num).toDouble(),
      image:j['image'],
      website:j['website'],
      phone:j['phone'],
      email:j['email'],
      price: j['price'],
      duration: _toMinutes(j['duration']),
      isByReservation: j['is_by_reservation'],
      staffFavorite:j['staff_favorite'], isActive:j['is_active'],
      createdAt: j['created_at']!=null?DateTime.tryParse(j['created_at']):null,
      currentPromotion: j['current_promotion']!=null?PromotionDto.fromJson(j['current_promotion']):null,
    );
  }
  ActivityDetailEntity toEntity()=>ActivityDetailEntity(
    id:id,
    name:name,
    description:description,
    categories:categories.map((e)=>e.toEntity()).toList(),
    primaryCategory: primaryCategory?.toEntity(),
    address:address,
    city:city,
    state:state,
    zipCode:zipCode,
    placeId:placeId,
    latitude:latitude,
    longitude:longitude,
    image:image,
    website:website,
    phone:phone,
    email:email,
    price:price,
    duration:duration,
    isByReservation: isByReservation,
    staffFavorite:staffFavorite,
    isActive:isActive,
    createdAt:createdAt,
    currentPromotion: currentPromotion?.toEntity(),
  );
}

class EventDetailDto {
  final String id;
  final String name;
  final String? description;
  final DateTime? start;
  final DateTime? end;
  final String? location,city,state,placeId;
  final double latitude, longitude;
  final List<CategoryDto> categories;
  final CategoryDto? primaryCategory;
  final String? website,image;
  final num? price;
  final int? duration;
  final bool? isByReservation;
  final bool? staffFavorite,isPublic;
  final DateTime? createdAt;
  final List<PromotionDto> promotions;
  final PromotionDto? currentPromotion;
  final bool? hasPromotion;
  EventDetailDto({
    required this.id, required this.name, this.description, this.start, this.end, this.location, this.city, this.state, this.placeId,
    required this.latitude, required this.longitude, required this.categories, this.primaryCategory, this.website, this.image,
    this.price, this.duration, this.isByReservation,
    this.staffFavorite, this.isPublic, this.createdAt, this.promotions = const [], this.currentPromotion, this.hasPromotion,
  });
  factory EventDetailDto.fromJson(Map<String,dynamic> j){
    final cats = (j['category'] as List? ?? []).map((e)=>CategoryDto.fromJson(e)).toList();
    final promos = (j['promotions'] as List? ?? []).map((e)=>PromotionDto.fromJson(e)).toList();
    return EventDetailDto(
      id: j['id'].toString(), name: j['name']??'', description:j['description'],
      start: j['start_datetime']!=null?DateTime.tryParse(j['start_datetime']):null,
      end: j['end_datetime']!=null?DateTime.tryParse(j['end_datetime']):null,
      location:j['location'],
      city:j['city'],
      state:j['state'], placeId:j['place_id'],
      latitude:(j['latitude'] as num).toDouble(),
      longitude:(j['longitude'] as num).toDouble(),
      categories: cats,
      primaryCategory: j['primary_category']!=null?CategoryDto.fromJson(j['primary_category']):null,
      website:j['website'],
      image:j['image'],
      price:j['price'],
      duration: _toMinutes(j['duration']),
      isByReservation: j['is_by_reservation'],
      staffFavorite:j['staff_favorite'],
      isPublic:j['is_public'],
      createdAt: j['created_at']!=null?DateTime.tryParse(j['created_at']):null,
      promotions: promos,
      currentPromotion: j['current_promotion']!=null?PromotionDto.fromJson(j['current_promotion']):null,
      hasPromotion:j['has_promotion'],
    );
  }
  EventDetailEntity toEntity()=>EventDetailEntity(
    id:id,
    name:name,
    description:description,
    start:start,
    end:end,
    location:location,
    city:city,
    state:state,
    placeId:placeId,
    latitude:latitude,
    longitude:longitude,
    categories:categories.map((e)=>e.toEntity()).toList(),
    primaryCategory: primaryCategory?.toEntity(),
    website:website,
    image:image,
    price:price,
    duration:duration,
    isByReservation: isByReservation,
    staffFavorite:staffFavorite,
    isPublic:isPublic,
    createdAt:createdAt,
    promotions: promotions.map((e)=>e.toEntity()).toList(), currentPromotion: currentPromotion?.toEntity(), hasPromotion:hasPromotion,
  );
}