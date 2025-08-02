//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :domain/usecases/auth/verify_registration_usecase.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:texas_buddy/domain/repositories/auth/auth_repository.dart';

/// Use case to verify a user’s registration number and email.
/// Returns the server message on success, or throws an AuthException.
class VerifyRegistrationUseCase {
  final AuthRepository _repository;

  VerifyRegistrationUseCase(this._repository);

  /// Calls [AuthRepository.verifyRegistration] with the given params.
  Future<String> call({
    required String email,
    required String signUpNumber,
  }) {
    return _repository.verifyRegistration(
      email: email,
      signUpNumber: signUpNumber,
    );
  }
}
