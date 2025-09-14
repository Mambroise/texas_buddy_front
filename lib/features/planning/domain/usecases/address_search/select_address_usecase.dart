//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/usecases/address_search/select_address_usecase.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:dartz/dartz.dart';
import 'package:texas_buddy/core/errors/failure.dart';
import '../../entities/address_selected.dart';
import '../../repositories/trip_repository.dart';

class SelectAddressParams {
  final String placeId;
  final String city;
  final String lang;
  SelectAddressParams({required this.placeId, required this.city, required this.lang});
}

class SelectAddressUseCase {
  final TripRepository repo;
  SelectAddressUseCase(this.repo);

  Future<Either<Failure, AddressSelected>> call(SelectAddressParams p) {
    return repo.selectAddress(placeId: p.placeId, city: p.city, lang: p.lang);
  }
}
