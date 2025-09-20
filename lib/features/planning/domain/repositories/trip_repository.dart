//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/repositories/trip_repository.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:dartz/dartz.dart';
import '../entities/trip.dart';
import 'package:texas_buddy/core/errors/failure.dart';
import 'package:texas_buddy/features/planning/domain/entities/address_suggestion.dart';
import 'package:texas_buddy/features/planning/domain/entities/address_selected.dart'; // NEW

abstract class TripRepository {
  Future<Trip> createTrip(TripCreate input);
  Future<List<Trip>> listTrips();
  Future<void> deleteTrip(int id);
  Future<Trip> updateTrip({
    required int id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    int? adults,
    int? children,
  });
  Future<Trip> getTripById(int id);

  // 🔄 Search: plus de sessionToken
  Future<Either<Failure, List<AddressSuggestion>>> searchAddressTx({
    required String city,
    required String q,
    required String lang,
    required int limit,
  });

  // 🆕 Select: Google Details côté back → id cache
  Future<Either<Failure, AddressSelected>> selectAddress({
    required String placeId,
    required String city,
    required String lang,
  });

  // 🆕 Patch TripDay avec l’id du cache
  Future<Either<Failure, void>> updateTripDayAddress({
    required int tripDayId,
    required int addressCacheId,
  });
}
