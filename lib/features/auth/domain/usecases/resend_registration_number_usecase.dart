//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :domain/usecases/auth/resend_registration_number_usecase.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:texas_buddy/features/auth/domain/repositories/auth_repository.dart';

/// Use case to resend the registration number to a given email.
class ResendRegistrationNumberUseCase {
  final AuthRepository _repo;
  ResendRegistrationNumberUseCase(this._repo);

  /// Calls AuthRepository.resendRegistrationNumber(email).
  Future<String> call({ required String email }) {
    // On success, the repository returns a message or throws AuthException.
    return _repo.resendRegistrationNumber(email: email)
        .then((_) => 'Registration number email sent.')
        .catchError((e) => throw e);
  }
}
