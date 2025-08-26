//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/domain/repositories/nearby_repositories.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';

class NearbyQuery {
  final double north, east, south, west;
  final int zoom;
  final List<String> categoryKeys;
  final double? centerLat;
  final double? centerLng;

  NearbyQuery({
    required this.north,
    required this.east,
    required this.south,
    required this.west,
    required this.zoom,
    required this.categoryKeys,
    this.centerLat,
    this.centerLng,
  });
}

abstract class NearbyRepository {
  Future<List<NearbyItem>> getNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
    int limit = 100,
  });

  /// Nouveau : requête “bounds-aware” pour la carte
  Future<List<NearbyItem>> getNearbyInBounds({
    required double north,
    required double south,
    required double east,
    required double west,
    required int zoom,
    List<String>? categoryKeys,
    int limit = 150,
    double? centerLat,   // pour tri/distance côté client si besoin
    double? centerLng,
  });

  /// Immediate cached list if fresh; null if nothing fresh.
  List<NearbyItem>? getCachedNearby(NearbyQuery q);

  /// Network fetch (and will refresh cache internally).
  Future<List<NearbyItem>> fetchNearby(NearbyQuery q);
}




