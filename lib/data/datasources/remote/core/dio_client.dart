//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :data/datasources/remote/core/dio_client.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:dio/dio.dart';

Dio createDioClient({ required String locale }) {
  return Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:8001/api/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: <String, Object?>{
        'Content-Type': 'application/json',
        'Accept-Language': locale,  // ← ici
      },
    ),
  )..interceptors.add(
    LogInterceptor(requestBody: true, responseBody: true),
  );
}
