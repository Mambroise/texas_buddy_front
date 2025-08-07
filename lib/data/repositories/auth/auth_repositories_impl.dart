//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/repositories/auth/auth_repository_impl.dart
// Author : Morice
//-------------------------------------------------------------------------



import 'package:dio/dio.dart';
import 'package:texas_buddy/domain/repositories/auth/auth_repository.dart';
import 'package:texas_buddy/data/datasources/remote/auth/auth_remote_datasource.dart';
import 'package:texas_buddy/data/datasources/local/token_storage.dart';

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
  final TokenStorage         _tokens;

  AuthRepositoryImpl(this._remote, this._tokens);


  @override
  Future<String> verifyRegistration({
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
  Future<String> verifyRegistration2FACode({
    required String email,
    required String code,
  }) async {
    try {
      return await _remote.verifyRegistration2FACode(
        email: email,
        code: code,
      );
    } on DioException catch (e) {
      final detail = e.response?.data['detail'] as String?;
      throw AuthException(detail ?? e.message ?? 'Verification failed');
    }
  }

  @override
  Future<String> setInitialPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _remote.setInitialPassword(
        email: email,
        password: password,
      );
    } on DioException catch (e) {
      final detail = e.response?.data['detail'] as String?;
      throw AuthException(detail ?? e.message ?? 'Password set failed');
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
    required String email,
    required String password,
  }) async {
    try {
      await _remote.setPassword(email: email, password: password);
    } on DioException catch (e) {
      final detail = e.response?.data['detail'] as String?;
      throw AuthException(detail ?? e.message ?? 'Set password failed');
    }
  }

  @override
  Future<void> verify2FACode({required String code}) async {
    // Implementation will call a corresponding remote method
    throw UnimplementedError();
  }

  @override
  Future<String> requestPasswordReset({ required String email }) async {
    try {
      return await _remote.requestPasswordReset(email: email);
    } on DioException catch (e) {
      final detail = e.response?.data['detail'] as String?;
      throw AuthException(detail ?? e.message ?? 'Request reset failed');
    }
  }

  @override
  Future<String> verifyResetPassword2FACode({
    required String email,
    required String code,
  }) async {
    try {
      return await _remote.verifyResetPassword2FACode(
        email: email,
        code: code,
      );
    } on DioException catch (e) {
      final detail = e.response?.data['detail'] as String?;
      throw AuthException(detail ?? e.message ?? '2FA verification failed');
    }
  }

  @override
  Future<void> login({
    required String email,
    required String password
  }) async {
    try {
      final tokens = await _remote.login(email: email, password: password);
      // Stocke les tokens
      await _tokens.saveTokens(
        access:  tokens['access']!,
        refresh: tokens['refresh']!,
      );
    } on DioException catch (e) {
      final detail = e.response?.data['detail'] as String?;
      throw AuthException(detail ?? e.message ?? 'Login failed');
    }
  }
}
