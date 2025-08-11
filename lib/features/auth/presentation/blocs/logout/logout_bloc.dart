//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/blocs/auth/resend_registration_bloc.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:texas_buddy/features/auth/domain/usecases/logout_usecase.dart';
import 'package:texas_buddy/app/router/auth_notifier.dart';

part 'logout_event.dart';
part 'logout_state.dart';


class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final LogoutUseCase _logoutUseCase;
  final AuthNotifier _auth; // 👈

  LogoutBloc(this._logoutUseCase, this._auth) : super(LogoutInitial()) {
    on<LogoutRequested>((event, emit) async {
      emit(LogoutInProgress());
      try {
        await _logoutUseCase();
        _auth.setLoggedOut();
        emit(LogoutSuccess());
      } catch (e) {
        emit(LogoutFailure(e.toString()));
      }
    });
  }
}


