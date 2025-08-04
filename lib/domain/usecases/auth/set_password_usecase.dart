//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :domain/usecases/auth/set_password_usecase.dart
// Author : Morice
//-------------------------------------------------------------------------


import '../../repositories/auth/auth_repository.dart';

class SetPasswordUseCase {
  final AuthRepository _repo;

  SetPasswordUseCase(this._repo);

  Future<void> call({
    required String password,
    required String confirmPassword,
  }) async {
    return _repo.setPassword(
      password: password,
      confirmPassword: confirmPassword,
    );
  }
}
