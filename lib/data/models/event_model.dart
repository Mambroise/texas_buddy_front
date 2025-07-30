//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/models/event_model.dart
// Author : Morice
//---------------------------------------------------------------------------


/// Event Model
class EventModel {
  final int? id;
  final String name;
  final String description;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final String? address;
  final String city;
  final String state;
  final String? zipCode;
  final String? location;
  final String? placeId;
  final double? latitude;
  final double? longitude;
  final String? website;
  final String? imageUrl;
  final double? price;
  final Duration? duration;
  final double averageRating;
  final bool staffFavorite;
  final bool isNational;
  final bool isPublic;
  final DateTime? createdAt;
  final List<int>? categoryIds;

  EventModel({
    this.id,
    required this.name,
    required this.description,
    required this.startDatetime,
    required this.endDatetime,
    this.address,
    required this.city,
    this.state = 'Texas',
    this.zipCode,
    this.location,
    this.placeId,
    this.latitude,
    this.longitude,
    this.website,
    this.imageUrl,
    this.price,
    this.duration,
    this.averageRating = 0.0,
    this.staffFavorite = false,
    this.isNational = false,
    this.isPublic = true,
    this.createdAt,
    this.categoryIds,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      startDatetime: DateTime.parse(map['start_datetime'] as String),
      endDatetime: DateTime.parse(map['end_datetime'] as String),
      address: map['address'] as String?,
      city: map['city'] as String,
      state: map['state'] as String,
      zipCode: map['zip_code'] as String?,
      location: map['location'] as String?,
      placeId: map['place_id'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      website: map['website'] as String?,
      imageUrl: map['image_url'] as String?,
      price: (map['price'] as num?)?.toDouble(),
      duration: map['duration'] != null ? Duration(milliseconds: int.parse(map['duration'] as String)) : null,
      averageRating: (map['average_rating'] as num).toDouble(),
      staffFavorite: (map['staff_favorite'] as int) == 1,
      isNational: (map['is_national'] as int) == 1,
      isPublic: (map['is_public'] as int) == 1,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
      categoryIds: null, // to be populated separately
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'start_datetime': startDatetime.toIso8601String(),
      'end_datetime': endDatetime.toIso8601String(),
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'location': location,
      'place_id': placeId,
      'latitude': latitude,
      'longitude': longitude,
      'website': website,
      'image_url': imageUrl,
      'price': price,
      'duration': duration?.inMilliseconds.toString(),
      'average_rating': averageRating,
      'staff_favorite': staffFavorite ? 1 : 0,
      'is_national': isNational ? 1 : 0,
      'is_public': isPublic ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
