//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/domain/usecases/get_event_detail.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:dartz/dartz.dart';
import '../entities/detail_models.dart';
import '../repositories/detail_repository.dart';


class GetEventDetail {
  final DetailRepository repo;
  GetEventDetail(this.repo);
  Future<Either<DetailFailure, EventDetailEntity>> byId(String id) => repo.getEventDetailById(id);
  Future<Either<DetailFailure, EventDetailEntity>> byPlace(String placeId) => repo.getEventDetailByPlaceId(placeId);
}