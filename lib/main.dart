//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : lib/main.dart
// Author : Morice
//---------------------------------------------------------------------------

// lib/main.dart
// lib/main.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:texas_buddy/core/l10n/current_locale.dart';   // ✅ CurrentLocale
import 'package:texas_buddy/core/network/dio_client.dart';    // ✅ createDioClient(CurrentLocale)
import 'package:texas_buddy/app/di/service_locator.dart';
import 'package:texas_buddy/app/router/auth_notifier.dart';
import 'package:texas_buddy/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ex: "fr-FR"
  final deviceLocale = PlatformDispatcher.instance.locale.toLanguageTag();

  // "fr" | "en" | "es" (fallback "en")
  final lang = deviceLocale.split(RegExp(r'[-_]')).first.toLowerCase();
  final currentLocale = CurrentLocale(
    (lang == 'en' || lang == 'fr' || lang == 'es') ? lang : 'en',
  );

  // Optionnel mais pratique si tu veux y accéder ailleurs (ex: depuis un BlocListener)
  getIt.registerSingleton<CurrentLocale>(currentLocale);

  // ✅ crée Dio avec l’interceptor de langue basé sur currentLocale
  final dio = createDioClient(currentLocale: currentLocale);

  // ✅ ta signature actuelle: setupLocator(Dio dio)
  await setupLocator(dio);

  await getIt<AuthNotifier>().init();

  runApp(TexasBuddyApp(deviceLocale: deviceLocale));
}
