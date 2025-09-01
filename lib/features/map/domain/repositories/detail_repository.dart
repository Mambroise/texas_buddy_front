import 'package:dartz/dartz.dart';
import 'package:texas_buddy/features/map/domain/entities/detail_models.dart';


sealed class DetailFailure {
  final String message;
  const DetailFailure(this.message);
}


class NetworkFailure extends DetailFailure { const NetworkFailure(super.message); }
class NotFoundFailure extends DetailFailure { const NotFoundFailure(super.message); }
class UnauthorizedFailure extends DetailFailure { const UnauthorizedFailure(super.message); }
class UnknownFailure extends DetailFailure { const UnknownFailure(super.message); }


abstract interface class DetailRepository {
  Future<Either<DetailFailure, ActivityDetailEntity>> getActivityDetailById(String id);
  Future<Either<DetailFailure, EventDetailEntity>> getEventDetailById(String id);


// Optional placeId variants
  Future<Either<DetailFailure, ActivityDetailEntity>> getActivityDetailByPlaceId(String placeId);
  Future<Either<DetailFailure, EventDetailEntity>> getEventDetailByPlaceId(String placeId);
}