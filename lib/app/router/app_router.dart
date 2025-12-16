//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : app/router/app_router.dart
// Author : Morice
//---------------------------------------------------------------------------


// lib/app/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:texas_buddy/features/auth/presentation/pages/splash_page.dart';
import 'package:texas_buddy/features/auth/presentation/pages/login_page.dart';
import 'package:texas_buddy/presentation/shell/landing_scaffold.dart';
import 'package:texas_buddy/app/di/service_locator.dart';
import 'package:texas_buddy/app/router/auth_notifier.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

enum AppRouteName { splash, login, landing }

class AppRouter {
  AppRouter._();

  static GoRouter build() {
    final auth = getIt<AuthNotifier>();

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/splash',
      refreshListenable: auth,
      redirect: (context, state) {
        final initialized = auth.initialized;
        final loggedIn = auth.isLoggedIn;
        final isSplash = state.matchedLocation == '/splash';
        final isLogin = state.matchedLocation == '/login';
        final isProtected = state.matchedLocation.startsWith('/landing');

        // Tant que pas initialisé → reste sur /splash
        if (!initialized && !isSplash) return '/splash';
        if (!initialized) return null;

        // Une fois initialisé :
        if (!loggedIn && isProtected) return '/login';
        if (!loggedIn && isSplash) return '/login';
        if (loggedIn && (isLogin || isSplash)) return '/landing';

        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/splash',
          name: AppRouteName.splash.name,
          builder: (_, __) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          name: AppRouteName.login.name,
          builder: (_, __) => const LoginPage(),
        ),
        GoRoute(
          path: '/landing',
          name: AppRouteName.landing.name,
          builder: (_, __) => const LandingScaffold(),
        ),
      ],
    );
  }
}
