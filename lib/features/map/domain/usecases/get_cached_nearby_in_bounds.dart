//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/domain/usecases/get_cached_nearby_in_bounds.dart
// Author : Morice
//---------------------------------------------------------------------------


import '../entities/nearby_item.dart';
import '../repositories/nearby_repository.dart';

class GetCachedNearbyInBounds {
  final NearbyRepository repo;
  GetCachedNearbyInBounds(this.repo);

  List<NearbyItem>? call({
    required double north,
    required double south,
    required double east,
    required double west,
    required int zoom,
    required List<String> categoryKeys,
    double? centerLat,
    double? centerLng,
  }) {
    return repo.getCachedNearby(NearbyQuery(
      north: north,
      south: south,
      east: east,
      west: west,
      zoom: zoom,
      categoryKeys: categoryKeys,
      centerLat: centerLat,
      centerLng: centerLng,
    ));
  }
}
