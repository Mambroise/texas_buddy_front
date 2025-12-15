import 'package:texas_buddy/features/planning/data/dtos/activity_dto.dart';
import 'package:texas_buddy/features/planning/data/dtos/event_dto.dart';
import 'package:texas_buddy/features/planning/data/dtos/advertisement_dto.dart';

/// Unified DTO for items returned by the /api/activities/nearby endpoint
class NearbyItemDto {
  final String type;
  final bool isAdvertisement;
  final double distance;
  final ActivityDto? activity;
  final EventDto? event;
  final AdvertisementDto? advertisement;

  NearbyItemDto({
    required this.type,
    required this.isAdvertisement,
    required this.distance,
    this.activity,
    this.event,
    this.advertisement,
  });

  factory NearbyItemDto.fromJson(Map<String, dynamic> json) {
    final itemType = json['type'] as String;
    final isAd = json['is_advertisement'] as bool;

    return NearbyItemDto(
      type: itemType,
      isAdvertisement: isAd,
      distance: (json['distance'] as num).toDouble(),
      activity: itemType == 'activity' && !isAd ? ActivityDto.fromJson(json) : null,
      event: itemType == 'event' ? EventDto.fromJson(json) : null,
      advertisement: isAd ? AdvertisementDto.fromJson(json) : null,
    );
  }

  Map<String, Object?> toJson() {
    final map = <String, Object?>{
      'type': type,
      'is_advertisement': isAdvertisement,
      'distance': distance,
    };

    // ✅ On garde ton comportement : on "flat" le contenu spécifique dans la map
    if (activity != null) map.addAll(activity!.toJson());
    if (event != null) map.addAll(event!.toJson());
    if (advertisement != null) map.addAll(advertisement!.toJson());

    return map;
  }
}
