//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/data/repositories/detail_repository_impl.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:dartz/dartz.dart';
import '../../domain/entities/detail_models.dart';
import '../../domain/repositories/detail_repository.dart';
import '../datasources/remote/detail_remote_datasource.dart';
import 'package:dio/dio.dart';


class DetailRepositoryImpl implements DetailRepository {
  final DetailRemoteDataSource remote;

  DetailRepositoryImpl(this.remote);


  @override
  Future<Either<DetailFailure, ActivityDetailEntity>> getActivityDetailById(
      String id) async {
    try {
      final dto = await remote.fetchActivityById(id);
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }


  @override
  Future<Either<DetailFailure, EventDetailEntity>> getEventDetailById(
      String id) async {
    try {
      final dto = await remote.fetchEventById(id);
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }


  @override
  Future<
      Either<DetailFailure, ActivityDetailEntity>> getActivityDetailByPlaceId(
      String placeId) async {
    try {
      final dto = await remote.fetchActivityByPlace(placeId);
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }


  @override
  Future<Either<DetailFailure, EventDetailEntity>> getEventDetailByPlaceId(
      String placeId) async {
    try {
      final dto = await remote.fetchEventByPlace(placeId);
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  DetailFailure _mapDio(DioException e) {
    final code = e.response?.statusCode ?? 0;
    if (code == 401) return const UnauthorizedFailure('Unauthorized');
    if (code == 404) return const NotFoundFailure('Not found');
    return NetworkFailure(e.message ?? 'Network error');
  }
}