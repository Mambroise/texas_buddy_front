//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : lib/main.dart
// Author : Morice
//---------------------------------------------------------------------------

// lib/main.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:texas_buddy/core/network/dio_client.dart';
import 'package:texas_buddy/app/di/service_locator.dart';
import 'package:texas_buddy/app/app.dart';
import 'package:texas_buddy/app/router/auth_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final deviceLocale = PlatformDispatcher.instance.locale.toLanguageTag(); // ex: "fr-FR"
  final dio = createDioClient(locale: deviceLocale);

  setupLocator(dio); // DI

  await getIt<AuthNotifier>().init();

  runApp(TexasBuddyApp(deviceLocale: deviceLocale));
}
