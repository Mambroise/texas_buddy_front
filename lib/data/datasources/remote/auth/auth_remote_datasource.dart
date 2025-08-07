//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/datasources/remote/auth/auth_remote_datasource.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:dio/dio.dart';

/// Remote data source for user authentication endpoints.
/// This class contains methods to call Django auth API.
class AuthRemoteDatasource {
  final Dio _dio;

  /// Creates an [AuthRemoteDatasource] using a pre-configured [Dio] instance.
  ///
  /// The [Dio] should have its base URL set to 'http://127.0.0.1:8001/api/'.
  AuthRemoteDatasource(this._dio);

  /// Verifies the user's registration number and email for first-time signup.
  ///
  /// Sends a POST request to '/auth/verify-registration/' with the
  /// following payload:
  /// ```json
  /// {
  ///   "email": "john.doe@example.com",
  ///   "sign_up_number": "ABC123"
  /// }
  /// ```
  ///
  /// Returns the server message on success (HTTP 200).
  /// Throws [DioException] on network or server-side validation errors.
  Future<String> verifyRegistration({
    required String email,
    required String signUpNumber,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'users/auth/verify-registration/',
      data: <String, Object?>{
        'email': email,
        'sign_up_number': signUpNumber,
      },
    );

    // Extract a message from the response JSON, adjust key as needed
    final message = response.data?['message'] as String?;
    if (message != null) {
      return message;
    }

    // Fallback: return entire response body as string
    return response.data.toString();
  }


  /// POST users/auth/verify-2fa-code/
  /// Body: { "email": ..., "code": ... }
  /// Returns { "message": ... } or throws on error.
  Future<String> verifyRegistration2FACode({
    required String email,
    required String code,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'users/auth/verify-2fa-code/',
      data: <String, Object?>{
        'email': email,
        'code': code,
      },
    );
    final data = res.data;
    final message = data?['message'] as String?;
    final detail = data?['detail'] as String?;

    return message ?? detail ?? data.toString();
  }


  /// Resends the registration number to the specified email.
  ///
  /// Sends a POST request to 'users/auth/resend-registration-number/'.
  /// Returns the 'message' field on success.
  Future<String> resendRegistrationNumber({
    required String email,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'users/auth/resend-registration-number/',
      data: <String, Object?>{
        'email': email,
      },
    );
    final message = response.data?['message'] as String?;
    if (message != null) {
      return message;
    }
    return response.data?['detail'] as String? ?? response.data.toString();
  }


  /// Verifies the 2FA code sent to the user after registration.
  ///
  /// Sends a POST request to 'users/auth/verify-2fa-code/'.
  /// Returns the 'message' field on success.
  Future<String> verify2FACode({
    required String email,
    required String code,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'users/auth/verify-2fa-code/',
      data: <String, Object?>{
        'email': email,
        'code': code,
      },
    );
    final message = response.data?['message'] as String?;
    if (message != null) {
      return message;
    }
    return response.data?['detail'] as String? ?? response.data.toString();
  }

  /// Sets iniatial password for the user after 2FA verification.
  ///
  /// Sends a POST request to 'users/auth/set-password/'.
  /// Returns the 'message' field on success.
  Future<String> setInitialPassword({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'users/auth/set-password/',
      data: <String, Object?>{
        'email': email,
        'password': password,
      },
    );

    final message = response.data?['message'] as String?;
    return message ?? response.data?['detail'] ?? 'Unexpected error';
  }

  /// Sets a new password for the user after 2FA verification.
  ///
  /// Sends a POST request to 'users/auth/password-reset/confirm'.
  /// Returns the 'message' field on success.
  Future<String> setPassword({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'users/password-reset/confirm/',
      data: <String, Object?>{
        'email': email,
        'password': password,
      },
    );
    final message = response.data?['message'] as String?;
    if (message != null) {
      return message;
    }
    return response.data?['detail'] as String? ?? response.data.toString();
  }


  /// Performs login and retrieves JWT access & refresh tokens.
  ///
  /// POST 'users/auth/login/'
  /// Body: { "email": ..., "password": ... }
  /// Returns a map { 'access': String, 'refresh': String }.
  /// Throws DioException on error; server returns 'detail' on 401/403.
  Future<Map<String, String>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'users/auth/login/',
      data: <String, Object?>{
        'email': email,
        'password': password,
      },
    );
    // On succès 200, réponse : { access: "...", refresh: "..." }
    final data = response.data!;
    return {
      'access': data['access'] as String,
      'refresh': data['refresh'] as String,
    };
  }


  /// POST users/password-reset/request/
  /// Body: { "email": ... }
  /// Returns { "message": ... } or throws on error.
  Future<String> requestPasswordReset({ required String email }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'users/password-reset/request/',
      data: <String, Object?>{ 'email': email },
    );
    // message on success, detail on failure
    final data = res.data;
    final message = data?['message'] as String?;
    final detail = data?['detail'] as String?;

    return message ?? detail ?? data.toString();

  }


  /// POST users/auth/verify-restpwd-2fa-code/
  /// Body: { "email": ..., "code": ... }
  /// Returns { "message": ... } or throws on error.
  Future<String> verifyResetPassword2FACode({
    required String email,
    required String code,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      'users/auth/verify-restpwd-2fa-code/',
      data: <String, Object?>{
        'email': email,
        'code': code,
      },
    );
    final data = res.data;
    final message = data?['message'] as String?;
    final detail = data?['detail'] as String?;

    return message ?? detail ?? data.toString();

  }
}
