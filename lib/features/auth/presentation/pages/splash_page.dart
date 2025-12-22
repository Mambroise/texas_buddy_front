//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/auth/presentation/pages/splash_page.dart
// Author : Morice
//---------------------------------------------------------------------------

/*
==============================================================================
SplashPage — Écran de démarrage logique
==============================================================================

🎯 Rôle principal
- Écran transitoire affiché au lancement de l’app.
- Décide de la première destination réelle de l’utilisateur.

🔁 Workflow
1) initState()
   - déclenche _initSession()

2) Vérification de session
   - CheckSessionUseCase :
     - tokens valides → utilisateur connecté
     - sinon → non connecté

3) Si connecté
   - tentative non bloquante de fetch du profil (/me)
   - redirection vers Landing

4) Si non connecté ou erreur
   - redirection vers Login

🎨 UI
- Affiche uniquement un loader + message localisé
- Aucune interaction utilisateur possible

📌 Pourquoi c’est important
- Centralise la logique de décision initiale
- Évite toute duplication de logique auth dans les pages
- Garantit une navigation propre dès le premier écran
==============================================================================
*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:texas_buddy/presentation/widgets/texas_buddy_loader.dart';
import 'package:texas_buddy/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:texas_buddy/app/di/service_locator.dart';
import 'package:texas_buddy/app/router/app_router.dart'; // AppRouteName
import 'package:texas_buddy/features/user/domain/usecases/fetch_and_cache_me_usecase.dart';

// L10n
import 'package:texas_buddy/core/l10n/l10n_ext.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _checkSessionUseCase = getIt<CheckSessionUseCase>();
  final _fetchMe = getIt<FetchAndCacheMeUseCase>();

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    try {
      final isLoggedIn = await _checkSessionUseCase();
      if (!mounted) return;
      if (isLoggedIn) {
        try {
          await _fetchMe();
        } catch (_) {
          // Non-blocking: even if /me fails, continue to app
        }
        context.goNamed(AppRouteName.landing.name);
      } else {
        context.goNamed(AppRouteName.login.name);
      }
    } catch (_) {
      if (!mounted) return;
      context.goNamed(AppRouteName.login.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: TexasBuddyLoader(message: l10n.splashWelcome),
    );
  }
}
