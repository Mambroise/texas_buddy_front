//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/data/repositories/nearby_repository_impl.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'dart:math' as math;
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';
import 'package:texas_buddy/features/map/domain/repositories/nearby_repository.dart';
import 'package:texas_buddy/features/map/data/datasources/remote/nearby_remote_datasource.dart';

class NearbyRepositoryImpl implements NearbyRepository {
  final NearbyRemoteDataSource remote;
  NearbyRepositoryImpl(this.remote);

  @override
  Future<List<NearbyItem>> getNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 25, // (pas utilisé par ton view — gardé pour future)
    int limit = 100,      // (page_size côté backend)
  }) async {
    // On mappe limit → page_size (et page=1)
    final dtos = await remote.fetchNearby(
      latitude: latitude,
      longitude: longitude,
      page: 1,
      pageSize: limit.clamp(1, 100),
    );

    var items = dtos.map((d) => d.toDomain()).toList();

    // Calcul distance locale si absente (sécu)
    double toRad(double d) => d * math.pi / 180.0;
    double haversineKm(double lat1, double lon1, double lat2, double lon2) {
      const R = 6371.0;
      final dLat = toRad(lat2 - lat1);
      final dLon = toRad(lon2 - lon1);
      final a = math.sin(dLat/2)*math.sin(dLat/2)
          + math.cos(toRad(lat1))*math.cos(toRad(lat2))
              * math.sin(dLon/2)*math.sin(dLon/2);
      final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
      return R * c;
    }

    for (var i = 0; i < items.length; i++) {
      if (items[i].distanceKm == null) {
        final d = haversineKm(latitude, longitude, items[i].latitude, items[i].longitude);
        items[i] = items[i].copyWith(distanceKm: d);
      }
    }

    // Tri client de sécurité: Ads -> hasPromotion -> distance croissante
    items.sort((a, b) {
      final adDelta = (b.isAdvertisement ? 1 : 0) - (a.isAdvertisement ? 1 : 0);
      if (adDelta != 0) return adDelta;
      final promoDelta = (b.hasPromotion ? 1 : 0) - (a.hasPromotion ? 1 : 0);
      if (promoDelta != 0) return promoDelta;
      final da = a.distanceKm ?? double.infinity;
      final db = b.distanceKm ?? double.infinity;
      return da.compareTo(db);
    });

    return items;
  }
}
