//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/dtos/event_dto.dart
// Author : Morice
//-------------------------------------------------------------------------

import 'package:texas_buddy/data/dtos/category_dto.dart';

/// Data Transfer Object for event data
class EventDto {
  final int id;
  final String name;
  final String description;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final String? location;
  final String city;
  final String state;
  final String? placeId;
  final double? latitude;
  final double? longitude;
  final List<CategoryDto> categories;
  final double? price;
  final bool staffFavorite;
  final bool hasPromotion;
  final double distance;

  EventDto({
    required this.id,
    required this.name,
    required this.description,
    required this.startDatetime,
    required this.endDatetime,
    this.location,
    required this.city,
    required this.state,
    this.placeId,
    this.latitude,
    this.longitude,
    required this.categories,
    this.price,
    required this.staffFavorite,
    required this.hasPromotion,
    required this.distance,
  });

  /// Creates an [EventDto] from a JSON map
  factory EventDto.fromJson(Map<String, dynamic> json) {
    return EventDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      startDatetime: DateTime.parse(json['start_datetime'] as String),
      endDatetime: DateTime.parse(json['end_datetime'] as String),
      location: json['location'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      placeId: json['place_id'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      categories: (json['category'] as List)
          .map((c) => CategoryDto.fromJson(c as Map<String, dynamic>))
          .toList(),
      price: (json['price'] as num?)?.toDouble(),
      staffFavorite: json['staff_favorite'] as bool,
      hasPromotion: json['has_promotion'] as bool,
      distance: (json['distance'] as num).toDouble(),
    );
  }

  /// Converts this [EventDto] to a JSON map
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'description': description,
      'start_datetime': startDatetime.toIso8601String(),
      'end_datetime': endDatetime.toIso8601String(),
      'location': location,
      'city': city,
      'state': state,
      'place_id': placeId,
      'latitude': latitude,
      'longitude': longitude,
      'category': categories.map((c) => c.toJson()).toList(),
      'price': price,
      'staff_favorite': staffFavorite,
      'has_promotion': hasPromotion,
      'distance': distance,
    };
  }
}