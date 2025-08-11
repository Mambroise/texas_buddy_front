//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :domain/usecases/auth/request_password_reset_usecase.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:texas_buddy/features/auth/domain/repositories/auth_repository.dart';

/// Use case to request a password reset code for a user.
class RequestPasswordResetUseCase {
  final AuthRepository _repo;
  RequestPasswordResetUseCase(this._repo);

  /// Calls [AuthRepository.requestPasswordReset].
  Future<String> call({ required String email }) {
    return _repo.requestPasswordReset(email: email);
  }
}
