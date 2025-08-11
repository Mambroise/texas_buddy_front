//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :domain/usecases/auth/set_password_usecase.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:texas_buddy/features/auth/domain/repositories/auth_repository.dart';


class SetPasswordUseCase {
  final AuthRepository _repo;

  SetPasswordUseCase(this._repo);

  Future<void> call({
    required String email,
    required String password,
  }) async {
    return _repo.setPassword(
      email: email,
      password: password,
    );
  }
}
