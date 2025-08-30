//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : core/errors/error_mapper.dart
// Author : Morice
//---------------------------------------------------------------------------


// lib/core/errors/error_mapper.dart
import 'package:dio/dio.dart';
import 'failure.dart';

Failure mapDioError(Object error) {
  if (error is DioException) {
    final r = error.response;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Failure.timeout();

      case DioExceptionType.badCertificate:
      // Problème TLS/SSL (certificat invalide/auto-signé/host mismatch)
      // On le traite comme une erreur réseau côté UX.
        return Failure.network();

      case DioExceptionType.badResponse:
        final code = r?.statusCode ?? 0;
        final msg  = _extractServerMsg(r?.data);
        switch (code) {
          case 401: return Failure.unauthorized();
          case 403: return Failure.forbidden();
          case 404: return Failure.notFound();
          case 409: return Failure.conflict();
          case 422: return Failure.validation(msg);
          case 429: return Failure.rateLimit();
          default:  return Failure.server(code, msg);
        }

      case DioExceptionType.cancel:
        return Failure.unknown('cancelled');

      case DioExceptionType.connectionError:
        return Failure.network();

      case DioExceptionType.unknown:
      // Très souvent: offline/DNS
        return Failure.network();
    }
  }

  if (error is FormatException || error is TypeError) {
    return Failure.parse(error.toString());
  }
  return Failure.unknown(error.toString());
}

String? _extractServerMsg(dynamic data) {
  if (data is Map && data['detail'] is String) return data['detail'] as String;
  if (data is Map && data['message'] is String) return data['message'] as String;
  return null;
}
