// lib/data/datasources/remote/core/auth_interceptor.dart

import 'package:dio/dio.dart';
import 'package:texas_buddy/core/storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final Dio          _dio;

  AuthInterceptor(this._tokenStorage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final access = await _tokenStorage.getAccessToken();
    if (access != null) {
      options.headers['Authorization'] = 'Bearer $access';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si Unauthorized, tente un refresh et réessaie
    if (err.response?.statusCode == 401) {
      final refresh = await _tokenStorage.getRefreshToken();
      if (refresh != null) {
        try {
          final resp = await _dio.post<Map<String,dynamic>>(
            'users/auth/token/refresh/',
            data: { 'refresh': refresh },
          );
          final newAccess = resp.data?['access'] as String;
          await _tokenStorage.saveTokens(access: newAccess, refresh: refresh);

          // Retry original request with new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccess';
          final cloneReq = await _dio.fetch(opts);
          return handler.resolve(cloneReq);
        } catch (_) {
          // refresh failed → clear tokens & forward error
          await _tokenStorage.clear();
        }
      }
    }
    return handler.next(err);
  }
}
