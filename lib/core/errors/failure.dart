//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : core/errors/failure.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'error_code.dart';

class Failure {
  final AppErrorCode code;
  final String? serverMessage; // message brut éventuel depuis l’API
  final int? statusCode;

  const Failure(this.code, {this.serverMessage, this.statusCode});

  // Helpers
  bool get isAuth => code == AppErrorCode.unauthorized || code == AppErrorCode.forbidden;

  // Factories courantes
  factory Failure.network()      => const Failure(AppErrorCode.network);
  factory Failure.timeout()      => const Failure(AppErrorCode.timeout);
  factory Failure.unauthorized() => const Failure(AppErrorCode.unauthorized);
  factory Failure.forbidden()    => const Failure(AppErrorCode.forbidden);
  factory Failure.notFound()     => const Failure(AppErrorCode.notFound);
  factory Failure.conflict()     => const Failure(AppErrorCode.conflict);
  factory Failure.rateLimit()    => const Failure(AppErrorCode.rateLimit);
  factory Failure.validation([String? msg]) => Failure(AppErrorCode.validation, serverMessage: msg);
  factory Failure.server([int? status, String? msg]) => Failure(AppErrorCode.server, statusCode: status, serverMessage: msg);
  factory Failure.parse([String? msg])      => Failure(AppErrorCode.parse, serverMessage: msg);
  factory Failure.unknown([String? msg])    => Failure(AppErrorCode.unknown, serverMessage: msg);
}
