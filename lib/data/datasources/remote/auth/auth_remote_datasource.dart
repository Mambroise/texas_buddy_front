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
  /// The [Dio] should have its base URL set to 'http://127.0.0.1:8001/api/users/'.
  AuthRemoteDatasource(this._dio);

  /// Verifies the user's registration number and email for first-time signup.
  ///
  /// Sends a POST request to '/auth/verify-registration/' with the
  /// following payload:
  /// ```json
  /// {
  ///   "last_name": "Doe",
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
      'auth/verify-registration/',
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
}
