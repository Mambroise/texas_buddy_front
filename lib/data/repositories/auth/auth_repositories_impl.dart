//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/repositories/auth/auth_repository_impl.dart
// Author : Morice
//-------------------------------------------------------------------------



import 'package:dio/dio.dart';
import 'package:texas_buddy/domain/repositories/auth/auth_repository.dart';
import 'package:texas_buddy/data/datasources/remote/auth/auth_remote_datasource.dart';

/// Exception type for authentication errors.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

/// Implementation of [AuthRepository] using remote data source.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;

  AuthRepositoryImpl(this._remote);

  @override
  Future<String> verifyRegistration({
    required String lastName,
    required String email,
    required String signUpNumber,
  }) async {
    try {
      return await _remote.verifyRegistration(
        email: email,
        signUpNumber: signUpNumber,
      );
    } on DioException catch (e) {
      final detail = e.response?.data['detail'] as String?;
      throw AuthException(detail ?? e.message ?? 'Unknown error occurred',);
    }
  }

  @override
  Future<void> resendRegistrationNumber({required String email}) async {
    try {
      await _remote.resendRegistrationNumber(email: email);
    } on DioException catch (e) {
      final detail = e.response?.data['detail'] as String?;
      throw AuthException(detail ?? e.message ?? 'Unknown error occurred',);
    }
  }

  @override
  Future<void> setPassword({
    required String password,
    required String confirmPassword,
  }) async {
    // Implementation will call a corresponding remote method
    throw UnimplementedError();
  }

  @override
  Future<void> verify2FACode({required String code}) async {
    // Implementation will call a corresponding remote method
    throw UnimplementedError();
  }
}
