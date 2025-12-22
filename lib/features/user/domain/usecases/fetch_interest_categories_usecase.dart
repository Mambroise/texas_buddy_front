//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/domain/usecases/fetch_interests_category_usecase.dart
// Author : Morice
//-------------------------------------------------------------------------


import '../entities/interest_category.dart';
import '../repositories/interests_repository.dart';

class FetchInterestCategoriesUseCase {
  final InterestsRepository repo;
  const FetchInterestCategoriesUseCase(this.repo);

  Future<List<InterestCategory>> call() => repo.fetchAllCategories();
}
