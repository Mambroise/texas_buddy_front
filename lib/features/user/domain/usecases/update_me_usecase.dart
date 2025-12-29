//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/domain/usecases/update_me_usecase.dart
// Author : Morice
//-------------------------------------------------------------------------

import 'package:texas_buddy/features/user/domain/entities/user_profile.dart';
import 'package:texas_buddy/features/user/domain/repositories/user_repository.dart';

class UpdateMeUseCase {
  final UserRepository repo;
  UpdateMeUseCase(this.repo);

  Future<UserProfile> call({
    String? email,
    String? address,
    String? phone,
    String? country,
  }) {
    return repo.updateMeAndCache(
      email: email,
      address: address,
      phone: phone,
      country: country,
    );
  }
}
