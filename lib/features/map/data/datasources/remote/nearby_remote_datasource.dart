//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/data/datasources/remote/nearby_remote_datasource.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:dio/dio.dart';
import 'package:texas_buddy/features/map/data/dtos/nearby_dtos.dart';

abstract class NearbyRemoteDataSource {
  Future<List<NearbyItemDto>> fetchNearby({
    required double latitude,
    required double longitude,
    String? date,        // "YYYY-MM-DD"
    String? type,        // "activity" | "event"
    String? category,    // name contains
    String? search,      // free text
    String? ordering,    // price, -price, name, -name, distance, -distance
    int page = 1,
    int pageSize = 30,
  });
}

class NearbyRemoteDataSourceImpl implements NearbyRemoteDataSource {
  final Dio _dio;
  NearbyRemoteDataSourceImpl(this._dio);

  @override
  Future<List<NearbyItemDto>> fetchNearby({
    required double latitude,
    required double longitude,
    String? date,
    String? type,
    String? category,
    String? search,
    String? ordering,
    int page = 1,
    int pageSize = 30,
  }) async {
    final res = await _dio.get(
      'activities/nearby/', // baseUrl déjà .../api/
      queryParameters: {
        'lat': latitude,
        'lng': longitude,   // 👈 backend = lng
        if (date != null) 'date': date,
        if (type != null) 'type': type,
        if (category != null) 'category': category,
        if (search != null) 'search': search,
        if (ordering != null) 'ordering': ordering,
        'page': page,
        'page_size': pageSize,
      },
    );

    final data = res.data;
    final list = (data is Map && data['results'] is List)
        ? List<Map<String, dynamic>>.from(data['results'] as List)
        : (data is List)
        ? List<Map<String, dynamic>>.from(data)
        : <Map<String, dynamic>>[];

    return list.map(NearbyItemDto.fromJson).toList();
  }
}
