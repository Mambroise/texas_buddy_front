//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :domain/usecases/auth/set_password_registration_usecase.dart
// Author : Morice
//-------------------------------------------------------------------------

import '../repositories/auth_repository.dart';

class SetPasswordForRegistrationUseCase {
  final AuthRepository _repo;

  SetPasswordForRegistrationUseCase(this._repo);

  Future<void> call({
    required String email,
    required String password,
  }) async {
    await _repo.setInitialPassword(email: email, password: password);
  }
}
