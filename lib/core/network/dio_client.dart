//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/datasources/remote/core/dio_client.dart
// Author : Morice
//-------------------------------------------------------------------------



import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import './auth_interceptor.dart';

/// Factory to create and configure a single Dio client for all API calls.
/// - Sends 'Accept-Language' header with user locale.
/// - Attaches authentication interceptor for JWT handling.
Dio createDioClient({ required String locale }) {
  final dio = Dio(
    BaseOptions(
      // POUR TÉLÉPHONE RÉEL SUR WIFI DE DIM (ton PC a l’IP 192.168.0.22 sur ce même wifi)
      baseUrl: 'http://192.168.0.22:8001/api/',

      // POUR ÉMULATEUR ANDROID :
      //baseUrl: 'http://10.0.2.2:8001/api/',

      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: <String, Object?>{
        'Content-Type': 'application/json',
        'Accept-Language': locale,
      },
    ),
  );

  // Auth interceptor: attaches JWT and handles refresh on 401
  final tokenStorage = TokenStorage();
  dio.interceptors.add(AuthInterceptor(tokenStorage, dio));

  // Logging interceptor for debugging
  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) => print(obj),
    ),
  );

  return dio;
}
