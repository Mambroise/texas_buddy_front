//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :features/planning/data/dtos/nearby_item_dto.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:texas_buddy/features/planning/data/dtos/activity_dto.dart';
import 'package:texas_buddy/features/planning/data/dtos/event_dto.dart';
import 'package:texas_buddy/features/planning/data/dtos/advertisement_dto.dart';

/// Unified DTO for items returned by the /api/activities/nearby endpoint
class NearbyItemDto {
  final String type;
  final bool isAdvertisement;

  /// ⛔️ Nearby endpoint no longer returns distance (computed later on detail open)
  final double? distance;

  final ActivityDto? activity;
  final EventDto? event;
  final AdvertisementDto? advertisement;

  NearbyItemDto({
    required this.type,
    required this.isAdvertisement,
    this.distance,
    this.activity,
    this.event,
    this.advertisement,
  });

  factory NearbyItemDto.fromJson(Map<String, dynamic> json) {
    final itemType = json['type'] as String;
    final isAd = json['is_advertisement'] as bool;

    final rawDistance = json['distance'];
    final parsedDistance = rawDistance is num ? rawDistance.toDouble() : null;

    return NearbyItemDto(
      type: itemType,
      isAdvertisement: isAd,
      distance: parsedDistance,
      activity: itemType == 'activity' && !isAd ? ActivityDto.fromJson(json) : null,
      event: itemType == 'event' ? EventDto.fromJson(json) : null,
      advertisement: isAd ? AdvertisementDto.fromJson(json) : null,
    );
  }

  Map<String, Object?> toJson() {
    final map = <String, Object?>{
      'type': type,
      'is_advertisement': isAdvertisement,
      if (distance != null) 'distance': distance,
    };

    // ✅ flat le contenu spécifique dans la map
    if (activity != null) map.addAll(activity!.toJson());
    if (event != null) map.addAll(event!.toJson());
    if (advertisement != null) map.addAll(advertisement!.toJson());

    return map;
  }
}
