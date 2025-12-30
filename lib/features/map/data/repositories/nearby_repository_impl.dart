//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/data/repositories/nearby_repository_impl.dart
// Author : Morice
//---------------------------------------------------------------------------


//---------------------------------------------------------------------------
// Data repository impl with in-memory cache TTL
//---------------------------------------------------------------------------


import '../../domain/entities/nearby_item.dart';
import '../../domain/repositories/nearby_repository.dart';
import 'package:texas_buddy/features/map/data/datasources/remote/nearby_remote_datasource.dart';
import 'package:texas_buddy/features/map/data/dtos/nearby_dtos.dart';

import '../cache/nearby_memory_cache.dart';

class NearbyRepositoryImpl implements NearbyRepository {
  NearbyRepositoryImpl(this.remote, this._cache);

  final NearbyRemoteDataSource remote;
  final NearbyMemoryCache _cache;

  // ----------------- CACHE API -----------------

  @override
  List<NearbyItem>? getCachedNearby(NearbyQuery q) {
    final key = _cache.makeKey(
      north: q.north, east: q.east, south: q.south, west: q.west, zoom: q.zoom,
    );
    return _cache.getFresh(key);
  }

  @override
  Future<List<NearbyItem>> fetchNearby(NearbyQuery q) async {
    // ⚠️ corrige: NearbyRemoteDataSource n'a PAS 'fetchBounds' → on utilise 'fetchNearbyInBounds'
    final raw = await remote.fetchNearbyInBounds(
      north: q.north,
      south: q.south,
      east:  q.east,
      west:  q.west,
      zoom:  q.zoom,
      categoryKeys: q.categoryKeys,
      limit: 0, // serveur gère cap, ou laisse 0 si ton backend interprète 0 = auto
      centerLat: q.centerLat,
      centerLng: q.centerLng,
    );

    final items = _toDomainList(raw);

    _stableSort(items);

    // MAJ cache
    final key = _cache.makeKey(
      north: q.north, east: q.east, south: q.south, west: q.west, zoom: q.zoom,
    );
    _cache.put(key, items);
    return items;
  }

  // ----------------- LEGACY/RADIUS -----------------

  @override
  Future<List<NearbyItem>> getNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
    int limit = 100,
  }) async {
    final pageSize = limit < 1 ? 1 : (limit > 100 ? 100 : limit);

    final raw = await remote.fetchNearby(
      latitude: latitude,
      longitude: longitude,
      page: 1,
      pageSize: pageSize,
    );

    final items = _toDomainList(raw);
    _stableSort(items);
    return items;
  }

  // ----------------- BOUNDS (carte) -----------------

  @override
  Future<List<NearbyItem>> getNearbyInBounds({
    required double north,
    required double south,
    required double east,
    required double west,
    required int zoom,
    List<String>? categoryKeys,
    int limit = 150,
    double? centerLat,
    double? centerLng,
  }) async {
    final cap = limit < 1 ? 1 : (limit > 300 ? 300 : limit);

    final raw = await remote.fetchNearbyInBounds(
      north: north,
      south: south,
      east:  east,
      west:  west,
      zoom:  zoom,
      categoryKeys: categoryKeys,
      limit: cap,
      centerLat: centerLat,
      centerLng: centerLng,
    );

    final items = _toDomainList(raw);
    _stableSort(items);
    return items;
  }

  // ----------------- helpers -----------------

  List<NearbyItem> _toDomainList(dynamic raw) {
    if (raw is List<NearbyItemDto>) {
      return raw.map((d) => d.toDomain()).toList(growable: false);
    }
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map((m) => NearbyItemDto.fromJson(m).toDomain())
          .toList(growable: false);
    }
    return const <NearbyItem>[];
  }

  void _stableSort(List<NearbyItem> items) {
    items.sort((a, b) {
      final adDelta = (b.isAdvertisement ? 1 : 0) - (a.isAdvertisement ? 1 : 0);
      if (adDelta != 0) return adDelta;

      final promoDelta = (b.hasPromotion ? 1 : 0) - (a.hasPromotion ? 1 : 0);
      if (promoDelta != 0) return promoDelta;

      // fallback stable: name (case-insensitive)
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

}
