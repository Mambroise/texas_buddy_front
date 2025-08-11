//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :lib/core/network/auth_interceptor.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'dart:async';
import 'package:dio/dio.dart';
import 'package:texas_buddy/core/storage/token_storage.dart';
import 'package:texas_buddy/app/router/auth_notifier.dart'; // optionnel (pour signaler logout)

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final Dio _dio;
  final AuthNotifier? _auth; // optionnel

  AuthInterceptor(this._tokenStorage, this._dio, {AuthNotifier? auth})
      : _auth = auth;

  static const String _refreshPath = 'users/auth/token/refresh/';

  // Verrou de concurrence: un seul refresh en cours
  Completer<String?>? _refreshCompleter;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final access = await _tokenStorage.getAccessToken();
    if (access != null && access.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $access';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final isRefreshCall = err.requestOptions.path.contains(_refreshPath);

    // Ne JAMAIS tenter de refresh si l'erreur concerne déjà l'appel de refresh
    if (status == 401 && !isRefreshCall) {
      try {
        final newToken = await _getOrRefreshToken();
        if (newToken == null || newToken.isEmpty) {
          // pas de token => on laisse passer l'erreur 401
          return handler.next(err);
        }

        // Rejouer la requête d'origine avec le nouveau token
        final ro = err.requestOptions;

        final newHeaders = Map<String, dynamic>.from(ro.headers);
        newHeaders['Authorization'] = 'Bearer $newToken';

        final Response re = await _dio.request(
          ro.path,
          data: ro.data,
          queryParameters: ro.queryParameters,
          options: Options(
            method: ro.method,
            headers: newHeaders,
            responseType: ro.responseType,
            contentType: ro.contentType,
            followRedirects: ro.followRedirects,
            receiveTimeout: ro.receiveTimeout,
            sendTimeout: ro.sendTimeout,
            extra: ro.extra,
            // NB: on reprend les autres flags si tu en utilises
          ),
          cancelToken: ro.cancelToken,
          onReceiveProgress: ro.onReceiveProgress,
          onSendProgress: ro.onSendProgress,
        );

        return handler.resolve(re);
      } catch (_) {
        // Refresh KO : purge + éventuelle notif logout
        await _tokenStorage.clear();
        _auth?.setLoggedOut();
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  Future<String?> _getOrRefreshToken() async {
    // Si un refresh est déjà en cours, on attend son résultat
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final refresh = await _tokenStorage.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return null;

    _refreshCompleter = Completer<String?>();

    try {
      final resp = await _dio.post<Map<String, dynamic>>(
        _refreshPath,
        data: {'refresh': refresh},
      );
      final newAccess = resp.data?['access'] as String?;
      if (newAccess == null || newAccess.isEmpty) {
        throw DioException(
          requestOptions: RequestOptions(path: _refreshPath),
          error: 'No access token returned by refresh',
        );
      }

      await _tokenStorage.saveTokens(access: newAccess, refresh: refresh);
      _refreshCompleter?.complete(newAccess);
      return newAccess;
    } catch (e) {
      _refreshCompleter?.completeError(e);
      rethrow;
    } finally {
      _refreshCompleter = null; // reset pour les prochains 401
    }
  }
}

