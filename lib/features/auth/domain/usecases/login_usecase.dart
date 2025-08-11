//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :domain/usecases/auth/login_usecase.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:texas_buddy/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _authRepository;
  LoginUseCase(this._authRepository);

  Future<void> call({ required String email, required String password }) {
    return _authRepository.login(email: email, password: password);
  }
}
