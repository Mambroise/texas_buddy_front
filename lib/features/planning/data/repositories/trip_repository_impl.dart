//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/repositories/trip_repository_impl.dart
// Author : Morice
//-------------------------------------------------------------------------


import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/remote/trip_remote_datasource.dart';
import 'package:dio/dio.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource remote;
  TripRepositoryImpl(this.remote);

  @override
  Future<Trip> createTrip(TripCreate input) async {
    try {
      return await remote.create(input);
    } on DioException catch (e) {
      // remonte un message propre (400 validations, etc.)
      final msg = _extractError(e);
      throw TripCreateFailure(msg);
    }
  }

  String _extractError(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        // DRF: { "field": ["error"] }
        final first = data.entries.first;
        final val = first.value;
        if (val is List && val.isNotEmpty) return '${first.key}: ${val.first}';
        if (val is String) return '${first.key}: $val';
      }
    } catch (_) {}
    return e.message ?? 'Network error';
  }
}

class TripCreateFailure implements Exception {
  final String message;
  TripCreateFailure(this.message);

  @override
  String toString() => 'TripCreateFailure($message)';
}
