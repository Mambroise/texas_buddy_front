//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/usecases/address_search/search_address_suggestions_usecase.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:dartz/dartz.dart';
import 'package:texas_buddy/core/errors/failure.dart';
import 'package:texas_buddy/features/planning/domain/entities/address_suggestion.dart';
import 'package:texas_buddy/features/planning/domain/repositories/trip_repository.dart';

class SearchAddressParams {
  final String city;
  final String q;
  final String lang;
  final int limit;

  SearchAddressParams({
    required this.city,
    required this.q,
    required this.lang,
    required this.limit,
  });
}

class SearchAddressSuggestionsUseCase {
  final TripRepository repo;
  SearchAddressSuggestionsUseCase(this.repo);

  Future<Either<Failure, List<AddressSuggestion>>> call(SearchAddressParams p) {
    return repo.searchAddressTx(
      city: p.city,
      q: p.q,
      lang: p.lang,
      limit: p.limit,
    );
  }
}
