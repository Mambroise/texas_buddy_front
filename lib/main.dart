//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : lib/main.dart
// Author : Morice
//---------------------------------------------------------------------------

/*
==============================================================================
main.dart — Point d’entrée de l’application
==============================================================================

🎯 Rôle principal
- Point de boot global de Texas Buddy.
- Initialise tout ce qui DOIT exister avant le premier frame :
  - bindings Flutter
  - langue courante
  - client réseau (Dio)
  - base de données locale
  - service locator (DI)
  - état d’authentification initial

🔁 Séquence d’initialisation (ordre critique)
1) WidgetsFlutterBinding.ensureInitialized()
   - requis pour toute initialisation async avant runApp

2) Détection de la langue système
   - ex: "fr-FR" → "fr"
   - fallback sécurisé sur "en"

3) CurrentLocale
   - stocke la langue active côté infra (API, headers, etc.)
   - enregistré en singleton dans getIt

4) Dio client
   - créé avec interceptor de langue basé sur CurrentLocale
   - garantit que chaque requête API connaît la langue active

5) Base de données locale (SQLite)
   - ouverture + création des tables IF NOT EXISTS
   - attendue AVANT l’initialisation des repositories

6) Service Locator (DI)
   - enregistre blocs, cubits, usecases, repositories, datasources
   - dépend de Dio et de la DB déjà prêts

7) AuthNotifier.init()
   - vérifie la session (token valide ou non)
   - prépare l’état d’authentification global

8) runApp()
   - lance TexasBuddyApp avec la locale device initiale

📌 Pourquoi ce fichier est critique
- Il garantit un démarrage cohérent :
  pas de requêtes réseau sans langue,
  pas de repository sans DB,
  pas de routing sans état d’authentification connu.
==============================================================================
*/


import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:texas_buddy/core/l10n/current_locale.dart';   // ✅ CurrentLocale
import 'package:texas_buddy/core/network/dio_client.dart';    // ✅ createDioClient(CurrentLocale)
import 'package:texas_buddy/app/di/service_locator.dart';
import 'package:texas_buddy/app/router/auth_notifier.dart';
import 'package:texas_buddy/app/app.dart';

// ← import DB provider (tu as placé le fichier dans lib/core/database)
import 'package:texas_buddy/core/database/db_provider.dart';

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

  // --- Initialise la BDD locale (création des tables IF NOT EXISTS)
  //     On attend ici l'ouverture pour s'assurer que la DB existe si d'autres
  //     composants (ex: service locator) en ont besoin au boot.
  await DBProvider.instance.db;

  // ✅ ta signature actuelle: setupLocator(Dio dio)
  await setupLocator(dio);

  await getIt<AuthNotifier>().init();

  runApp(TexasBuddyApp(deviceLocale: deviceLocale));
}