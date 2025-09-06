//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : app/app.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:texas_buddy/app/router/app_router.dart';
import 'package:texas_buddy/app/di/service_locator.dart';
import 'package:texas_buddy/core/theme/app_theme.dart';
import 'package:texas_buddy/core/l10n/current_locale.dart';
import 'package:texas_buddy/features/map/presentation/blocs/location/location_bloc.dart';

// L10n (gen-l10n)
import 'package:texas_buddy/core/l10n/generated/l10n.dart';
import 'package:texas_buddy/core/l10n/locale_cubit.dart';


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
        // ✅ remets LocationBloc ici
        BlocProvider<LocationBloc>(
          create: (_) => getIt<LocationBloc>(),
        ),

        // (déjà présent)
        BlocProvider<LocaleCubit>(
          create: (_) {
            final parts = widget.deviceLocale.split(RegExp(r'[-_]'));
            final lang = (parts.isNotEmpty ? parts[0].toLowerCase() : 'en');
            final initial = (lang == 'en' || lang == 'fr' || lang == 'es')
                ? Locale(lang)
                : const Locale('en');
            final cubit = LocaleCubit(initial: initial);
            cubit.loadSaved();
            return cubit;
          },
        ),
      ],
      child: BlocListener<LocaleCubit, LocaleState>(
        listenWhen: (p, n) => p.locale != n.locale,
        listener: (_, state) {
          getIt<CurrentLocale>().setFromLocale(state.locale);
        },
        child: BlocBuilder<LocaleCubit, LocaleState>(
          builder: (ctx, localeState) {
            return MaterialApp.router(
              onGenerateTitle: (ctx) => L10n.of(ctx).appTitle,
              theme: AppTheme.lightTheme,
              locale: localeState.locale,
              localizationsDelegates: L10n.localizationsDelegates,
              supportedLocales: L10n.supportedLocales,
              routerConfig: _router,
            );
          },
        ),
      ),
    );
  }
}

