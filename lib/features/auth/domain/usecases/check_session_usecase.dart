//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :domain/usecases/auth/check_session_usecase.dart
// Author : Morice
//-------------------------------------------------------------------------

import 'package:texas_buddy/features/auth/domain/repositories/auth_repository.dart';

class CheckSessionUseCase {
  final AuthRepository _repo;

  CheckSessionUseCase(this._repo);

  /// Retourne true si la session est encore valide, sinon false.
  Future<bool> call() => _repo.checkSession();
}
