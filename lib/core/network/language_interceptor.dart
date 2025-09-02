// lib/core/network/language_interceptor.dart
import 'package:dio/dio.dart';
import 'package:texas_buddy/core/l10n/current_locale.dart';

class LanguageInterceptor extends Interceptor {
  final CurrentLocale _current;

  LanguageInterceptor(this._current);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Met à jour systématiquement (pratique si Dio a été créé avant changement de langue)
    options.headers['Accept-Language'] = _current.value; // "fr" | "en" | "es"
    handler.next(options);
  }
}
