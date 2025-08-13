//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/domain/repositories/nearby_repositories.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';

abstract class NearbyRepository {
  Future<List<NearbyItem>> getNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
    int limit = 100,
  });
}
