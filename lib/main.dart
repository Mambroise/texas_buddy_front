//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :lib/main.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'dart:ui'; // pour PlatformDispatcher
import 'package:texas_buddy/data/datasources/remote/core/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:texas_buddy/presentation/pages/auth/login_page.dart';
import 'package:texas_buddy/presentation/pages/auth/signup_page.dart';
import 'package:texas_buddy/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Récupère la locale courante via PlatformDispatcher
  final deviceLocale = PlatformDispatcher.instance.locale.toLanguageTag(); // ex: "fr-FR"

  // Crée ton Dio en passant la locale
  final dio = createDioClient(locale: deviceLocale);
  setupLocator(); // GetIt : enregistre AuthRepository, LoginUseCase, etc.
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Texas Buddy',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
      routes: {
        '/login': (_) => LoginPage(),
        '/signup': (_) => SignupPage(),  // à créer ensuite
        //'/home': (_) => HomePage(),      // écran post-login
      },
    );
  }
}


