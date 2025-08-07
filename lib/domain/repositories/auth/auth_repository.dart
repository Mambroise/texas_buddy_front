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

  /// Verifies the 2FA code sent to user registering
  Future<String> verifyRegistration2FACode({
    required String email,
    required String code,
  });

  /// Resends the registration number to the given email.
  /// Throws [AuthException] on failure.
  Future<void> resendRegistrationNumber({
    required String email,
  });

  /// Sets the user's password after verification.
  /// Throws [AuthException] on failure.
  Future<void> setPassword({
    required String email,
    required String password,
  });

  /// Sets the user's password after registration.
  /// Throws [AuthException] on failure.
  Future<String> setInitialPassword({
    required String email,
    required String password,
  });

  /// Verifies the 2FA code sent to user when reseting forgotten pwd .
  /// Throws [AuthException] on failure.
  Future<void> verify2FACode({
    required String code,
  });

  /// Logs in user and stores tokens locally.
  /// Throws [AuthException] on failure.
  Future<void> login({
    required String email,
    required String password,
  });

  /// Request a password reset 2FA code for a logged‐in user.
  /// Returns the server message ("Security code has been sent by email.").
  Future<String> requestPasswordReset({
    required String email
  });

  /// Verify the password‐reset 2FA code.
  /// Returns the server message ("code valid. You can now set your password").
  Future<String> verifyResetPassword2FACode({
    required String email,
    required String code,
  });
}
