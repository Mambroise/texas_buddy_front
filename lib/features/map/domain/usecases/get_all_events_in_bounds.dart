//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/domain/usecases/get_all_events_in_bounds.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:texas_buddy/features/map/domain/repositories/all_events_repository.dart';
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';

class GetAllEventsInBounds {
  final AllEventsRepository repo;
  GetAllEventsInBounds(this.repo);

  Future<List<NearbyItem>> call({
    required double north,
    required double south,
    required double east,
    required double west,
    required int zoom,
    int? year,
    bool useCache = true,
    String? localeHeader,
  }) =>
      repo.getInBounds(
        north: north, south: south, east: east, west: west, zoom: zoom,
        year: year, useCache: useCache, localeHeader: localeHeader,
      );
}
