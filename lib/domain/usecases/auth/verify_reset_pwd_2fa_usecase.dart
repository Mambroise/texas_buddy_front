//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :domain/usecases/auth/verify_reset_pwd_2fa_usecase.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:texas_buddy/domain/repositories/auth/auth_repository.dart';

class VerifyResetPwd2FACodeUseCase {
  final AuthRepository repository;

  VerifyResetPwd2FACodeUseCase(this.repository);

  Future<String> call({
    required String email,
    required String code
  }) {
    return repository.verifyResetPassword2FACode(email: email, code: code);
  }
}
