//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : data/repositories/trip_repository_impl.dart
// Author : Morice
//---------------------------------------------------------------------------


import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/remote/trip_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:texas_buddy/core/errors/failure.dart';
import '../../domain/entities/address_suggestion.dart';
import '../../domain/entities/address_selected.dart';

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

  @override
  Future<Either<Failure, List<AddressSuggestion>>> searchAddressTx({
    required String city,
    required String q,
    required String lang,
    required int limit,
  }) async {
    try {
      final items = await remote.searchAddressTx(
        city: city, q: q, lang: lang, limit: limit,
      );
      return Right(items);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final detail = e.response?.data is Map<String, dynamic>
          ? (e.response!.data['detail']?.toString())
          : e.message;

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(Failure.timeout());
      }
      if (status == 401) return Left(Failure.unauthorized());
      if (status == 403) return Left(Failure.forbidden());
      if (status == 404) return Left(Failure.notFound());
      if (status == 409) return Left(Failure.conflict());
      if (status == 429) return Left(Failure.rateLimit());

      return Left(Failure.server(status, detail));
    } catch (e) {
      return Left(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AddressSelected>> selectAddress({
    required String placeId,
    required String city,
    required String lang,
  }) async {
    try {
      final r = await remote.selectAddress(placeId: placeId, city: city, lang: lang);
      return Right(r);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final detail = e.response?.data is Map<String, dynamic>
          ? (e.response!.data['detail']?.toString())
          : e.message;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(Failure.timeout());
      }
      return Left(Failure.server(status, detail));
    } catch (e) {
      return Left(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTripDayAddress({
    required int tripDayId,
    required int addressCacheId,
  }) async {
    try {
      await remote.updateTripDayAddress(tripDayId: tripDayId, addressCacheId: addressCacheId);
      return const Right(null);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final detail = e.response?.data is Map<String, dynamic>
          ? (e.response!.data['detail']?.toString())
          : e.message;
      return Left(Failure.server(status, detail));
    } catch (e) {
      return Left(Failure.unknown(e.toString()));
    }
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


class TripGetFailure implements Exception {
  final String message;
  TripGetFailure(this.message);
  @override
  String toString() => 'TripGetFailure($message)';
}


