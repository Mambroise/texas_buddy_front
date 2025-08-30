//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :auth/domain/usecases/logout_usecase.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:texas_buddy/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repo;

  LogoutUseCase(this._repo);

  Future<void> call() => _repo.logout();
}
