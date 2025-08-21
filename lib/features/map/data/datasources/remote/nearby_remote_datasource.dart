//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/data/datasources/remote/nearby_remote_datasource.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:dio/dio.dart';
import 'package:texas_buddy/features/map/data/dtos/nearby_dtos.dart';

abstract class NearbyRemoteDataSource {
  Future<dynamic> fetchNearby({
    required double latitude,
    required double longitude,
    int page,
    int pageSize,
  });

  /// Nouveau : interroge le backend avec north/south/east/west/zoom/limit (+ catégories)
  Future<dynamic> fetchNearbyInBounds({
    required double north,
    required double south,
    required double east,
    required double west,
    required int zoom,
    List<String>? categoryKeys,
    int limit = 150,
    double? centerLat,
    double? centerLng,
  });
}

class NearbyRemoteDataSourceImpl implements NearbyRemoteDataSource {
  final Dio dio;
  NearbyRemoteDataSourceImpl(this.dio);

  @override
  Future<dynamic> fetchNearby({
    required double latitude,
    required double longitude,
    int page = 1,
    int pageSize = 100,
  }) async {
    final res = await dio.get(
      'activities/nearby/',
      queryParameters: {
        'lat': latitude,
        'lng': longitude,
        'page': page,
        'page_size': pageSize,
      },
    );
    final data = res.data;
    // Retour paginé DRF : { count, next, previous, results: [...] }
    if (data is Map<String, dynamic>) {
      return NearbyItemDto.listFromPagedJson(data);
    }
    return data;
  }

  @override
  Future<dynamic> fetchNearbyInBounds({
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
    final qp = <String, dynamic>{
      'north': north,
      'south': south,
      'east':  east,
      'west':  west,
      'zoom':  zoom,
      'limit': limit,
    };
    if (centerLat != null && centerLng != null) {
      qp['lat'] = centerLat;
      qp['lng'] = centerLng;
    }

    // Répéter ?category=fa-xxx pour chaque clé
    final options = Options();
    final uri = Uri(
      path: 'activities/nearby/',
      queryParameters: qp.map((k, v) => MapEntry(k, v.toString())),
    );

    // Petit “hack” pour répéter le paramètre category
    final extraQuery = StringBuffer(uri.query);
    if (categoryKeys != null && categoryKeys.isNotEmpty) {
      for (final c in categoryKeys) {
        if (extraQuery.isNotEmpty) extraQuery.write('&');
        extraQuery.write('category=$c');
      }
    }
    final fullUrl = '${uri.path}?${extraQuery.toString()}';

    final res = await dio.get(fullUrl, options: options);
    final data = res.data;

    // Ici aussi, le backend renvoie un objet paginé
    if (data is Map<String, dynamic>) {
      return NearbyItemDto.listFromPagedJson(data);
    }
    return data;
  }
}
