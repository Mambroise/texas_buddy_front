//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/models/activity_model.dart
// Author : Morice
//-------------------------------------------------------------------------


/// Activity Model
class ActivityModel {
  final int? id;
  final String name;
  final String description;
  final String address;
  final String city;
  final String state;
  final String? zipCode;
  final String? location;
  final String? placeId;
  final String? website;
  final String? phone;
  final String? email;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final double? price;
  final Duration? duration;
  final double averageRating;
  final bool staffFavorite;
  final bool isUnique;
  final bool isActive;
  final DateTime? createdAt;
  final List<int>? categoryIds;

  ActivityModel({
    this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    this.state = 'Texas',
    this.zipCode,
    this.location,
    this.placeId,
    this.website,
    this.phone,
    this.email,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.price,
    this.duration,
    this.averageRating = 0.0,
    this.staffFavorite = false,
    this.isUnique = false,
    this.isActive = true,
    this.createdAt,
    this.categoryIds,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      address: map['address'] as String,
      city: map['city'] as String,
      state: map['state'] as String,
      zipCode: map['zip_code'] as String?,
      location: map['location'] as String?,
      placeId: map['place_id'] as String?,
      website: map['website'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      imageUrl: map['image_url'] as String?,
      price: (map['price'] as num?)?.toDouble(),
      duration: map['duration'] != null ? Duration(milliseconds: int.parse(map['duration'] as String)) : null,
      averageRating: (map['average_rating'] as num).toDouble(),
      staffFavorite: (map['staff_favorite'] as int) == 1,
      isUnique: (map['is_unique'] as int) == 1,
      isActive: (map['is_active'] as int) == 1,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      categoryIds: null, // to be populated separately
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'location': location,
      'place_id': placeId,
      'website': website,
      'phone': phone,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
      'price': price,
      'duration': duration?.inMilliseconds.toString(),
      'average_rating': averageRating,
      'staff_favorite': staffFavorite ? 1 : 0,
      'is_unique': isUnique ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}