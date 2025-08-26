// lib/features/events/data/repositories/all_events_repository_impl.dart
import 'package:texas_buddy/features/map/domain/repositories/all_events_repository.dart';
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';
import '../datasources/remote/all_events_remote_datasource.dart';
import '../cache/all_events_cache.dart';

class AllEventsRepositoryImpl implements AllEventsRepository {
  final AllEventsRemoteDataSource remote;
  final AllEventsCache cache;

  AllEventsRepositoryImpl({required this.remote, required this.cache});

  @override
  Future<List<NearbyItem>> getInBounds({
    required double north,
    required double south,
    required double east,
    required double west,
    required int zoom,
    int? year,
    bool useCache = true,
    String? localeHeader,
  }) async {
    if (useCache) {
      final cached = cache.get(north, south, east, west, zoom);
      if (cached != null) return cached;
    }

    final items = await remote.getAllEventsInBounds(
      north: north, south: south, east: east, west: west, zoom: zoom, year: year, localeHeader: localeHeader,
    );

    cache.put(north, south, east, west, zoom, items);
    return items;
  }

  @override
  void clearCache() => cache.clear();
}
