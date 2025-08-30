//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : app/app.dart
// Author : Morice
//---------------------------------------------------------------------------


// app/app.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:texas_buddy/app/router/app_router.dart';
import 'package:texas_buddy/app/di/service_locator.dart';
import 'package:texas_buddy/core/theme/app_theme.dart';
import 'package:texas_buddy/features/map/presentation/blocs/location/location_bloc.dart';

// 👇 import du code généré par gen-l10n
import 'package:texas_buddy/core/l10n/generated/l10n.dart';


class TexasBuddyApp extends StatefulWidget {
  final String deviceLocale; // ex: "fr-FR"
  const TexasBuddyApp({super.key, required this.deviceLocale});

  @override
  State<TexasBuddyApp> createState() => _TexasBuddyAppState();
}

class _TexasBuddyAppState extends State<TexasBuddyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.build();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationBloc>(create: (_) => getIt<LocationBloc>()),
      ],
      child: MaterialApp.router(
        // 🔤 Titre localisé
        onGenerateTitle: (ctx) => L10n.of(ctx).appTitle,

        theme: AppTheme.lightTheme,

        // ❌ Retire ceci pour laisser Flutter choisir la locale avec la callback
        // locale: Locale(widget.deviceLocale.split('-').first),

        // ✅ Locales supportées
        supportedLocales: const [
          Locale('en'),
          Locale('fr'),
          Locale('es', 'MX'),
        ],

        // ✅ Delegates (d’abord le tien)
        localizationsDelegates: const [
          L10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],

        // ✅ Résolution: es -> es_MX, sinon fr/en, sinon fallback en
        localeListResolutionCallback: (locales, supported) {
          if (locales == null || locales.isEmpty) return const Locale('en');

          for (final device in locales) {
            // correspondance exacte (fr, es_MX, en)
            for (final sup in supported) {
              final sameLang = device.languageCode == sup.languageCode;
              final countryOk = sup.countryCode == null || device.countryCode == sup.countryCode;
              if (sameLang && countryOk) return sup;
            }
            // espagnol générique -> es_MX
            if (device.languageCode == 'es') return const Locale('es', 'MX');
            // fallback fr / en si générique
            if (device.languageCode == 'fr') return const Locale('fr');
            if (device.languageCode == 'en') return const Locale('en');
          }
          return const Locale('en');
        },

        routerConfig: _router,
      ),
    );
  }
}
