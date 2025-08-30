//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/domain/usecases/get_cached_user_usecase.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:texas_buddy/features/user/domain/entities/user_profile.dart';
import 'package:texas_buddy/features/user/domain/repositories/user_repository.dart';

class GetCachedUserUseCase {
  final UserRepository repo;
  GetCachedUserUseCase(this.repo);

  Future<UserProfile?> call() => repo.getCachedUser();
}
