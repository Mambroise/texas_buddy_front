import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:texas_buddy/presentation/pages/auth/login_page.dart';
import 'package:texas_buddy/service_locator.dart';
import 'package:texas_buddy/data/datasources/remote/core/dio_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final deviceLocale = PlatformDispatcher.instance.locale.toLanguageTag(); // ex: "fr-FR"
  final dio = createDioClient(locale: deviceLocale);

  setupLocator(dio); // 🧠 ← très important ici

  runApp(const MaterialApp(
    home: LoginPage(),
    debugShowCheckedModeBanner: false,
  ));
}
