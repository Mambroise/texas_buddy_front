//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/domain/repositories/all_events_repository.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';

abstract class AllEventsRepository {
  Future<List<NearbyItem>> getInBounds({
    required double north,
    required double south,
    required double east,
    required double west,
    required int zoom,
    int? year,
    bool useCache = true,
    String? localeHeader,
  });

  void clearCache();
}
