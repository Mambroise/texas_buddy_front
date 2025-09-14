//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/usecases/address_search/update_tripday_address_usecase.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:dartz/dartz.dart';
import 'package:texas_buddy/core/errors/failure.dart';
import '../../repositories/trip_repository.dart';

class UpdateTripDayAddressParams {
  final int tripDayId;
  final int addressCacheId;
  UpdateTripDayAddressParams({required this.tripDayId, required this.addressCacheId});
}

class UpdateTripDayAddressUseCase {
  final TripRepository repo;
  UpdateTripDayAddressUseCase(this.repo);

  Future<Either<Failure, void>> call(UpdateTripDayAddressParams p) {
    return repo.updateTripDayAddress(tripDayId: p.tripDayId, addressCacheId: p.addressCacheId);
  }
}
