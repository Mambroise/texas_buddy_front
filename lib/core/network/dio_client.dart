//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :lib/core/network/dio_client.dart
// Author : Morice
//-------------------------------------------------------------------------


// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:texas_buddy/core/storage/token_storage.dart';
import 'package:texas_buddy/core/network/auth_interceptor.dart';
// Optionnel: si tu veux notifier le routeur en cas de refresh KO
import 'package:texas_buddy/app/router/auth_notifier.dart';

/// Crée et configure le client Dio pour toute l'appli.
/// - Définit `Accept-Language`
/// - Branche l'AuthInterceptor (JWT + refresh + retry)
/// - Ajoute un LogInterceptor en dernier (debug)
Dio createDioClient({
  required String locale,
  AuthNotifier? authNotifier, // optionnel (si tu veux rediriger au refresh KO)
}) {
  final dio = Dio(
    BaseOptions(
      // POUR TÉLÉPHONE RÉEL SUR WIFI (ton PC a l’IP 192.168.0.22)
      baseUrl: 'http://192.168.0.22:8001/api/',
      // POUR ÉMULATEUR ANDROID :
      // baseUrl: 'http://10.0.2.2:8001/api/',

      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: <String, Object?>{
        'Content-Type': 'application/json',
        'Accept-Language': locale, // ✅ important
      },
    ),
  );

  // Storage pour tokens
  final tokenStorage = TokenStorage();

  // Interceptor d'auth (avec verrou de refresh + retry)
  dio.interceptors.add(AuthInterceptor(tokenStorage, dio, auth: authNotifier));

  // Logging (en dernier pour voir le résultat après retry/refresh)
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
