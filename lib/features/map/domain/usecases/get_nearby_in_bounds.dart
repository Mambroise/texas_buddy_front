//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/domain/usecases/get_nearby_in_bounds.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';
import 'package:texas_buddy/features/map/domain/repositories/nearby_repository.dart';

class GetNearbyInBounds {
  final NearbyRepository repository;
  GetNearbyInBounds(this.repository);

  Future<List<NearbyItem>> call({
    required double north,
    required double south,
    required double east,
    required double west,
    required int zoom,
    List<String>? categoryKeys,
    int limit = 150,
    double? centerLat,
    double? centerLng,
  }) {
    return repository.getNearbyInBounds(
      north: north,
      south: south,
      east: east,
      west: west,
      zoom: zoom,
      categoryKeys: categoryKeys,
      limit: limit,
      centerLat: centerLat,
      centerLng: centerLng,
    );
  }
}
