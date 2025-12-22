//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : app/router/auth_notifier.dart
// Author : Morice
//---------------------------------------------------------------------------

/*
==============================================================================
AuthNotifier — État d’authentification global
==============================================================================

🎯 Rôle principal
- Fournit un état simple et observable de l’authentification :
  - application initialisée ou non
  - utilisateur connecté ou non

🔁 Fonctionnement
- init()
  - appelle CheckSessionUseCase
  - vérifie la validité de la session (tokens)
  - déclenche notifyListeners()

- setLoggedIn()
  - appelé après un login réussi

- setLoggedOut()
  - appelé après logout ou expiration de session

📌 Utilisation
- Principalement consommé par le router (GoRouter)
  pour décider :
  - Splash
  - Login
  - Landing

🧠 Pourquoi un ChangeNotifier ici ?
- Très léger
- Suffisant pour un état binaire (logged in / out)
- Facilement observable par le router
==============================================================================
*/


import 'package:flutter/foundation.dart';
import 'package:texas_buddy/features/auth/domain/usecases/check_session_usecase.dart';

class AuthNotifier extends ChangeNotifier {
  final CheckSessionUseCase _checkSessionUseCase;

  bool _initialized = false;
  bool _isLoggedIn = false;

  bool get initialized => _initialized;
  bool get isLoggedIn => _isLoggedIn;

  AuthNotifier(this._checkSessionUseCase);

  Future<void> init() async {
    _isLoggedIn = await _checkSessionUseCase();

    _initialized = true;
    notifyListeners();
  }

  void setLoggedIn() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void setLoggedOut() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
