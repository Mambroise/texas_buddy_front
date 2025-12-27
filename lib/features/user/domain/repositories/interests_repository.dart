//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/domain/repositories/interests_repository.dart
// Author : Morice
//-------------------------------------------------------------------------

import '../entities/interest_category.dart';

abstract class InterestsRepository {
  Future<List<InterestCategory>> fetchAllCategories();
}
