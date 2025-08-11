//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : app/app.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:texas_buddy/app/router/app_router.dart';
import 'package:texas_buddy/app/di/service_locator.dart';
import 'package:texas_buddy/core/theme/app_theme.dart';

// Blocs globaux (ex: localisation)
import 'package:texas_buddy/features/map/presentation/blocs/location/location_bloc.dart';

class TexasBuddyApp extends StatefulWidget {
  final String deviceLocale;
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
    final languageCode = widget.deviceLocale.split('-').first;
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationBloc>(create: (_) => getIt<LocationBloc>()),
        // Ajoute d’autres blocs globaux ici si besoin
      ],
      child: MaterialApp.router(
        title: 'Texas Buddy',
        theme: AppTheme.lightTheme,
        locale: Locale(languageCode),
        supportedLocales: const [Locale('en'), Locale('fr'), Locale('es')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: _router, // 👈 GoRouter branché ici
      ),
    );
  }
}
