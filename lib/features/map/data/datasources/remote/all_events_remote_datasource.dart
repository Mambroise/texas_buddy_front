//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/data/datasources/remote/all_events_remote_datasource.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:dio/dio.dart';
import 'package:texas_buddy/features/map/data/dtos/nearby_dtos.dart';
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';

abstract class AllEventsRemoteDataSource {
  Future<List<NearbyItem>> getAllEventsInBounds({
    required double north,
    required double south,
    required double east,
    required double west,
    required int zoom,
    int? year,             // optionnel
    String? localeHeader,  // si tu veux forcer Accept-Language
  });
}

class AllEventsRemoteDataSourceImpl implements AllEventsRemoteDataSource {
  final Dio dio;
  AllEventsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<NearbyItem>> getAllEventsInBounds({
    required double north,
    required double south,
    required double east,
    required double west,
    required int zoom,
    int? year,
    String? localeHeader,
  }) async {
    final res = await dio.get(
      // ⚠️ route 1bis ci-dessous: /events/in-bounds/
      'events/in-bounds/',
      queryParameters: {
        'north': north,
        'south': south,
        'east':  east,
        'west':  west,
        'zoom':  zoom,
        if (year != null) 'year': year,
      },
      options: localeHeader == null ? null : Options(headers: {'Accept-Language': localeHeader}),
    );

    // Le backend renvoie une liste (-> cf. 1bis). On réutilise NearbyItemDto.
    final list = NearbyItemDto.listFromJsonArray(res.data as List);

    // Si le backend n’ajoute pas `type: "event"`, on force le kind côté domaine.
    return list.map((dto) => dto.toDomain().copyWith(kind: NearbyKind.event)).toList();
  }
}
