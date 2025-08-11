//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : app/router/auth_notifier.dart
// Author : Morice
//---------------------------------------------------------------------------


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
