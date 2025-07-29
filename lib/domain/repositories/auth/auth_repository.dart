//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :domain/repositories/auth_repository.dart
// Author : Morice
//-------------------------------------------------------------------------



/// Defines authentication-related operations available to the domain layer.
abstract class AuthRepository {
  /// Verifies the user's registration with last name, email, and sign-up number.
  /// Returns a server message on success.
  /// Throws [AuthException] on failure.
  Future<String> verifyRegistration({
    required String email,
    required String signUpNumber,
  });

  /// Resends the registration number to the given email.
  /// Throws [AuthException] on failure.
  Future<void> resendRegistrationNumber({
    required String email,
  });

  /// Sets the user's password after verification.
  /// Throws [AuthException] on failure.
  Future<void> setPassword({
    required String password,
    required String confirmPassword,
  });

  /// Verifies the 2FA code sent to user.
  /// Throws [AuthException] on failure.
  Future<void> verify2FACode({
    required String code,
  });
}