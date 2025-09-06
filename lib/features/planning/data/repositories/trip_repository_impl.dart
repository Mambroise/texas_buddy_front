//---------------------------------------------------------------------------
// File   : data/repositories/trip_repository_impl.dart
// Author : Morice
//---------------------------------------------------------------------------


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
      final msg = _extractError(e);
      throw TripCreateFailure(msg);
    }
  }

  @override
  Future<List<Trip>> listTrips() async {
    try {
      return await remote.list();
    } on DioException catch (e) {
      final msg = _extractError(e);
      throw TripListFailure(msg);
    }
  }

  @override
  Future<void> deleteTrip(int id) async {
    try {
      await remote.delete(id);
    } on DioException catch (e) {
      final msg = _extractError(e);
      throw TripDeleteFailure(msg);
    }
  }

  @override
  Future<Trip> updateTrip({
    required int id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    int? adults,
    int? children,
  }) async {
    try {
      return await remote.update(
        id: id,
        title: title,
        startDate: startDate,
        endDate: endDate,
        adults: adults,
        children: children,
      );
    } on DioException catch (e) {
      final msg = _extractError(e);
      throw TripUpdateFailure(msg);
    }
  }

  // ✅ NEW
  @override
  Future<Trip> getTripById(int id) async {
    try {
      return await remote.get(id);
    } on DioException catch (e) {
      final msg = _extractError(e);
      throw TripGetFailure(msg);
    }
  }

  String _extractError(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
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

class TripListFailure implements Exception {
  final String message;
  TripListFailure(this.message);
  @override
  String toString() => 'TripListFailure($message)';
}

class TripDeleteFailure implements Exception {
  final String message;
  TripDeleteFailure(this.message);
  @override
  String toString() => 'TripDeleteFailure($message)';
}

class TripUpdateFailure implements Exception {
  final String message;
  TripUpdateFailure(this.message);
  @override
  String toString() => 'TripUpdateFailure($message)';
}

// ✅ NEW
class TripGetFailure implements Exception {
  final String message;
  TripGetFailure(this.message);
  @override
  String toString() => 'TripGetFailure($message)';
}


