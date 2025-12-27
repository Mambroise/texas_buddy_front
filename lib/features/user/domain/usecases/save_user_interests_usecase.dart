//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/domain/usecases/save_user_interests_usecase.dart
// Author : Morice
//-------------------------------------------------------------------------

import '../repositories/user_interests_repository.dart';

class SaveUserInterestsUseCase {
  final UserInterestsRepository repo;
  const SaveUserInterestsUseCase(this.repo);

  Future<void> call({required List<int> categoryIds}) {
    return repo.saveInterests(categoryIds: categoryIds);
  }
}
