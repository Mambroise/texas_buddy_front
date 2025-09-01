//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/domain/usecases/get_activity_detail.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:dartz/dartz.dart';
import '../entities/detail_models.dart';
import '../repositories/detail_repository.dart';


class GetActivityDetail {
  final DetailRepository repo;
  GetActivityDetail(this.repo);
  Future<Either<DetailFailure, ActivityDetailEntity>> byId(String id) => repo.getActivityDetailById(id);
  Future<Either<DetailFailure, ActivityDetailEntity>> byPlace(String placeId) => repo.getActivityDetailByPlaceId(placeId);
}