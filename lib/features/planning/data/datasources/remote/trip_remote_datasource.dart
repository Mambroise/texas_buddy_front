//---------------------------------------------------------------------------
// File   : data/datasources/remote/trip_remote_datasource.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:dio/dio.dart';
import '../../dtos/trip_dto.dart';
import '../../../domain/entities/trip.dart';
import '../../../domain/entities/address_suggestion.dart';
import '../../../domain/entities/address_selected.dart';

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

  Future<Trip> get(int id);
  Future<List<AddressSuggestion>> searchAddressTx({
    required String city,
    required String q,
    required String lang,
    required int limit,
  });

  Future<AddressSelected> selectAddress({
    required String placeId,
    required String city,
    required String lang,
  });

  Future<void> updateTripDayAddress({
    required int tripDayId,
    required int addressCacheId,
  });
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

  // rechercher une adresse dans le back
  @override
  Future<List<AddressSuggestion>> searchAddressTx({
    required String city,
    required String q,
    required String lang,
    required int limit,
  }) async {
    final res = await dio.get(
      'planners/address/search-tx/', // ✅ pas de slash initial, et pas "planners/"
      queryParameters: {
        'city': city,
        'q': q,
        'lang': lang,
        'limit': limit,
      },
    );
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map((m) => AddressSuggestion(
      placeId: m['place_id'] as String,
      name: m['name'] as String,
      formattedAddress: m['formatted_address'] as String?,
      lat: (m['lat'] as num?)?.toDouble(),
      lng: (m['lng'] as num?)?.toDouble(),
      city: m['city'] as String?,
      stateCode: m['state_code'] as String?,
      countryCode: m['country_code'] as String?,
      source: m['source'] as String?,
      addressCacheId: m['address_cache_id'] as int?, // ✅ si source = cache
    )).toList();
  }

  @override
  Future<AddressSelected> selectAddress({
    required String placeId,
    required String city,
    required String lang,
  }) async {
    final res = await dio.post(
      'planners/address/select/',
      data: {
        'place_id': placeId,
        'city': city,
        'lang': lang,
      },
    );
    final m = (res.data as Map<String, dynamic>);
    return AddressSelected(
      addressCacheId: m['address_cache_id'] as int,
      placeId: m['place_id'] as String,
      formattedAddress: m['formatted_address'] as String?,
      lat: (m['lat'] as num?)?.toDouble(),
      lng: (m['lng'] as num?)?.toDouble(),
      city: m['city'] as String?,
      stateCode: m['state_code'] as String?,
      countryCode: m['country_code'] as String?,
    );
  }

  @override
  Future<void> updateTripDayAddress({
    required int tripDayId,
    required int addressCacheId,

  }) async {
    print('coucoucou');
    print(tripDayId);
    print(addressCacheId);
    await dio.patch(
      'planners/trip-days/$tripDayId/',
      data: {'address_cache_id': addressCacheId}, //
    );
  }
}