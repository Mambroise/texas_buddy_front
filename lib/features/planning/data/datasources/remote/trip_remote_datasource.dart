//---------------------------------------------------------------------------
// File   : data/datasources/remote/trip_remote_datasource.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:dio/dio.dart';
import '../../dtos/trip_dto.dart';
import '../../../domain/entities/trip.dart';

abstract class TripRemoteDataSource {
  Future<Trip> create(TripCreate input);
  Future<List<Trip>> list();
  Future<void> delete(int id);
  Future<Trip> update({
    required int id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    int? adults,
    int? children,
  });

  // ✅ NEW
  Future<Trip> get(int id);
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final Dio dio;
  TripRemoteDataSourceImpl(this.dio);

  // ⚠️ SANS slash initial, car baseUrl = http://.../api/
  static const _base = 'planners/trips/';

  @override
  Future<Trip> create(TripCreate input) async {
    final resp = await dio.post(_base, data: input.toJson());
    final dto = TripDto.fromJson(resp.data as Map<String, dynamic>);
    return dto.toEntity();
  }

  @override
  Future<List<Trip>> list() async {
    final resp = await dio.get(_base);
    final data = resp.data;
    if (data is List) {
      return data
          .cast<Map<String, dynamic>>()
          .map((j) => TripDto.fromJson(j).toEntity())
          .toList();
    } else {
      final results = (data as Map<String, dynamic>)['results'] as List<dynamic>? ?? const [];
      return results
          .cast<Map<String, dynamic>>()
          .map((j) => TripDto.fromJson(j).toEntity())
          .toList();
    }
  }

  @override
  Future<void> delete(int id) async {
    await dio.delete('$_base$id/'); // ex: /api/planners/trips/12/
  }

  @override
  Future<Trip> update({
    required int id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    int? adults,
    int? children,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (startDate != null) body['start_date'] = startDate.toIso8601String().split('T').first;
    if (endDate != null) body['end_date'] = endDate.toIso8601String().split('T').first;
    if (adults != null) body['adults'] = adults;
    if (children != null) body['children'] = children;

    final resp = await dio.patch('$_base$id/', data: body);
    final dto = TripDto.fromJson(resp.data as Map<String, dynamic>);
    return dto.toEntity();
  }

  // ✅ NEW — GET un trip complet (days + steps)
  @override
  Future<Trip> get(int id) async {
    // ton exemple fonctionne sans trailing slash : /api/planners/trips/22
    final resp = await dio.get('$_base$id');
    final dto = TripDto.fromJson(resp.data as Map<String, dynamic>);
    return dto.toEntity();
  }
}