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
// 👇 IMPORTANT: on importe le DTO pour avoir .toDomain()
import 'package:texas_buddy/features/map/data/dtos/nearby_dtos.dart';

class NearbyRepositoryImpl implements NearbyRepository {
  final NearbyRemoteDataSource remote;
  NearbyRepositoryImpl(this.remote);

  @override
  Future<List<NearbyItem>> getNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
    int limit = 100,
  }) async {
    // Clamp propre en int
    final pageSize = limit < 1 ? 1 : (limit > 100 ? 100 : limit);

    // Peut renvoyer List<NearbyItemDto> ou List<Map<String,dynamic>>
    final raw = await remote.fetchNearby(
      latitude: latitude,
      longitude: longitude,
      page: 1,
      pageSize: pageSize,
    );

    final List<NearbyItem> items = _toDomainList(raw);

    // Calcul distance locale si absente (sécurité)
    double toRad(double d) => d * math.pi / 180.0;
    double haversineKm(double lat1, double lon1, double lat2, double lon2) {
      const R = 6371.0;
      final dLat = toRad(lat2 - lat1);
      final dLon = toRad(lon2 - lon1);
      final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.cos(toRad(lat1)) *
              math.cos(toRad(lat2)) *
              math.sin(dLon / 2) *
              math.sin(dLon / 2);
      final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
      return R * c;
    }

    for (var i = 0; i < items.length; i++) {
      if (items[i].distanceKm == null) {
        final d = haversineKm(
          latitude,
          longitude,
          items[i].latitude,
          items[i].longitude,
        );
        items[i] = items[i].copyWith(distanceKm: d);
      }
    }

    // Tri client: Ads -> hasPromotion -> distance croissante
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

  // Convertit la réponse brute en liste non nulle de NearbyItem
  List<NearbyItem> _toDomainList(dynamic raw) {
    if (raw is List<NearbyItemDto>) {
      // Chemin “propre” : la datasource renvoie déjà des DTO typés
      return raw.map((d) => d.toDomain()).toList(growable: false);
    }
    if (raw is List) {
      // Chemin “fallback” : la datasource renvoie du JSON brut
      return raw
          .whereType<Map<String, dynamic>>()
          .map((m) => NearbyItemDto.fromJson(m).toDomain())
          .toList(growable: false);
    }
    return const <NearbyItem>[];
  }
}
