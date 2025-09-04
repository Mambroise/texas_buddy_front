//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/datasources/remote/trip_remonte_datasource.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:dio/dio.dart';
import '../../dtos/trip_dto.dart';
import '../../../domain/entities/trip.dart';

abstract class TripRemoteDataSource {
  Future<Trip> create(TripCreate input);
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final Dio dio;
  TripRemoteDataSourceImpl(this.dio);

  static const _base = '/planners/trips/';

  @override
  Future<Trip> create(TripCreate input) async {
    final resp = await dio.post(_base, data: input.toJson());
    final dto = TripDto.fromJson(resp.data as Map<String, dynamic>);
    return dto.toEntity();
  }
}
