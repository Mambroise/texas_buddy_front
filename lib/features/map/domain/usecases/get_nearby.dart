//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/domain/usecases/get_nearby_stream.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';
import 'package:texas_buddy/features/map/domain/repositories/nearby_repository.dart';

class GetNearby {
  final NearbyRepository repository;
  GetNearby(this.repository);

  Future<List<NearbyItem>> call({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
    int limit = 100,
  }) {
    return repository.getNearby(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      limit: limit,
    );
  }
}
