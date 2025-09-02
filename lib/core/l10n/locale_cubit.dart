import 'dart:ui' show PlatformDispatcher;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleState extends Equatable {
  final Locale locale;
  const LocaleState(this.locale);
  @override
  List<Object?> get props => [locale];
}

class LocaleCubit extends Cubit<LocaleState> {
  static const _kKey = 'app_locale'; // 'en' | 'fr' | 'es'

  /// [initial] est utilisé pour injecter la langue du device au boot.
  /// Si non fournie, on lit la locale plateforme.
  LocaleCubit({Locale? initial})
      : super(LocaleState(initial ?? _platformLocale()));

  static Locale _platformLocale() {
    final d = PlatformDispatcher.instance.locale;
    final lang = d.languageCode.toLowerCase();
    // Ne garde que les langues supportées, sinon fallback en
    if (lang == 'en' || lang == 'fr' || lang == 'es') {
      return Locale(lang);
    }
    return const Locale('en');
  }

  Future<void> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kKey);
    if (code != null && code.isNotEmpty) {
      emit(LocaleState(Locale(code)));
    }
  }

  Future<void> setLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, code);
    emit(LocaleState(Locale(code)));
  }

  Future<void> setEnglish() => setLocale('en');
  Future<void> setFrench()  => setLocale('fr');
  Future<void> setSpanish() => setLocale('es');
}
