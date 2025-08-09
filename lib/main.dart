//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :lib/main.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'dart:ui';
import 'package:texas_buddy/data/datasources/remote/core/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:texas_buddy/presentation/pages/auth/login_page.dart';
import 'package:texas_buddy/presentation/pages/main/landing_page.dart';
import 'package:texas_buddy/presentation/pages/splash/splash_page.dart';
import 'package:texas_buddy/service_locator.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final deviceLocale = PlatformDispatcher.instance.locale.toLanguageTag(); // ex: "fr-FR"
  final dio = createDioClient(locale: deviceLocale);
  setupLocator(dio);

  runApp(TexasBuddyApp(deviceLocale: deviceLocale));
}

class TexasBuddyApp extends StatelessWidget {

  final String deviceLocale;

  const TexasBuddyApp({super.key, required this.deviceLocale});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Texas Buddy',
      theme: AppTheme.lightTheme,
      locale: Locale(deviceLocale.split('-')[0]),
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('es'),
      ],
      routes: {
        '/splash': (context) => const SplashPage(),
        '/': (context) => const LoginPage(),
        '/landing': (context) => const LandingPage(),
      },
      initialRoute: '/splash',
    );
  }
}


