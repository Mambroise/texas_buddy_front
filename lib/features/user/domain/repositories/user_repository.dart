//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/domain/repositories/user_repository.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:texas_buddy/features/user/domain/entities/user_profile.dart';

abstract class UserRepository {
  Future<UserProfile> fetchMeAndCache();       // GET /me -> cache sqlite
  Future<UserProfile?> getCachedUser();        // sqlite only
  Future<void> upsertLocal(UserProfile user);  // utilitaire
  Future<void> clearLocal();
}
