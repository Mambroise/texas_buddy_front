//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :lib/main.dart
// Author : Morice
//-------------------------------------------------------------------------


// lib/main.dart

import 'dart:ui'; // pour PlatformDispatcher
import 'package:texas_buddy/data/datasources/remote/core/dio_client.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Récupère la locale courante via PlatformDispatcher
  final deviceLocale = PlatformDispatcher.instance.locale.toLanguageTag(); // ex: "fr-FR"

  // Crée ton Dio en passant la locale
  final dio = createDioClient(locale: deviceLocale);

  //runApp(MyApp(dio: dio));
}

