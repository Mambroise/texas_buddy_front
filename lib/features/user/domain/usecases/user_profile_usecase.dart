//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/domain/usecases/check_session_usecase.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:texas_buddy/features/user/domain/entities/user_profile.dart';
import 'package:texas_buddy/features/user/domain/repositories/user_repository.dart';

class FetchAndCacheMeUseCase {
  final UserRepository repo;
  FetchAndCacheMeUseCase(this.repo);

  Future<UserProfile> call() => repo.fetchMeAndCache();
}
