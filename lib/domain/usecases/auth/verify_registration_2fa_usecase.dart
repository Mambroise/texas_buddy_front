//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :domain/usecases/auth/verify_registration_2fa_usecase.dart
// Author : Morice
//-------------------------------------------------------------------------


import '../../repositories/auth/auth_repository.dart';

class VerifyRegistration2FACodeUseCase {
  final AuthRepository _repo;

  VerifyRegistration2FACodeUseCase(this._repo);

  Future<String> call({
    required String email,
    required String code,
  }) async {
    return _repo.verifyRegistration2FACode(email: email, code: code);
  }
}
