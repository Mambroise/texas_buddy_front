//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : data/datasources/remote/travel_remote_datasource.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:dio/dio.dart';

class TravelRemoteDatasource {
  final Dio _dio;
  TravelRemoteDatasource(this._dio);

  /// Appelle /api/planners/transport/estimate/
  Future<(int minutes, int meters)> estimate({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String mode = 'driving',
    String? lang,
  }) async {
    final res = await _dio.post(
      'planners/transport/estimate/', // baseUrl de ton Dio = "/api/"
      data: {
        'origin': {'lat': originLat, 'lng': originLng},
        'destination': {'lat': destLat, 'lng': destLng},
        'mode': mode,
        if (lang != null && lang.isNotEmpty) 'lang': lang,
      },
      // headers: Accept-Language est déjà géré par ton client global
    );

    final data = res.data as Map<String, dynamic>;
    final minutes = (data['duration_minutes'] as num?)?.toInt() ?? 0;
    final meters  = (data['distance_meters'] as num?)?.toInt() ?? 0;

    // clamp simple (jamais négatif)
    return (minutes < 0 ? 0 : minutes, meters < 0 ? 0 : meters);
  }
}
