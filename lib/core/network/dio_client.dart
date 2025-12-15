//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :lib/core/network/dio_client.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:dio/dio.dart';
import 'package:texas_buddy/core/storage/token_storage.dart';
import 'package:texas_buddy/core/network/auth_interceptor.dart';
import 'package:texas_buddy/core/network/language_interceptor.dart';
import 'package:texas_buddy/core/l10n/current_locale.dart';
import 'package:texas_buddy/app/router/auth_notifier.dart';
import 'package:flutter/foundation.dart';

Dio createDioClient({
  required CurrentLocale currentLocale,
  AuthNotifier? authNotifier,
}) {
  final dio = Dio(
    BaseOptions(
      //baseUrl: 'http://192.168.0.15:8001/api/',// maison
      // baseUrl: 'http://192.168.1.20:8001/api/', // teddy
      //baseUrl: 'http://192.168.1.153:8001/api/', // laura
      //baseUrl: 'http://10.0.2.2:8001/api/', // emul 10.87.3.167
      baseUrl: 'http://10.87.3.167:8001/api/',// Partage con



      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: <String, Object?>{
        'Content-Type': 'application/json',
        // Valeur par défaut au boot (l’interceptor assurera les maj ensuite)
        'Accept-Language': currentLocale.value,
      },
    ),
  );

  final tokenStorage = TokenStorage();

  // IMPORTANT: Language avant Auth, Logging en dernier
  dio.interceptors.add(LanguageInterceptor(currentLocale));
  if (kDebugMode) {
    dio.interceptors.add(AuthInterceptor(tokenStorage, dio, auth: authNotifier));
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: false,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) => print(obj),
    ));
  }
  return dio;
}
