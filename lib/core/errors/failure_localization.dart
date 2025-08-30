//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : core/errors/failure_localization.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter/widgets.dart';
import 'package:texas_buddy/core/l10n/l10n_ext.dart';
import 'failure.dart';
import 'error_code.dart';

extension FailureX on Failure {
  String localizedMessage(BuildContext context) {
    final l10n = context.l10n;
    // si le serveur a un message pertinent, tu peux le retourner pour validation par ex.
    if (code == AppErrorCode.validation && (serverMessage?.isNotEmpty ?? false)) {
      return serverMessage!;
    }
    switch (code) {
      case AppErrorCode.network:      return l10n.networkError;
      case AppErrorCode.timeout:      return l10n.timeoutError;
      case AppErrorCode.unauthorized: return l10n.unauthorizedError;
      case AppErrorCode.forbidden:    return l10n.forbiddenError;
      case AppErrorCode.notFound:     return l10n.notFoundError;
      case AppErrorCode.conflict:     return l10n.conflictError;
      case AppErrorCode.rateLimit:    return l10n.rateLimitError;
      case AppErrorCode.validation:   return l10n.validationError; // fallback si pas de serverMessage
      case AppErrorCode.server:       return l10n.serverUnavailable;
      case AppErrorCode.parse:        return l10n.parseError;
      case AppErrorCode.unknown:      return l10n.somethingWentWrong;
    }
  }
}
