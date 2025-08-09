//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/blocs/auth/resend_registration_bloc.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:texas_buddy/domain/usecases/auth/logout_usecase.dart';

part 'logout_event.dart';
part 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final LogoutUseCase _logoutUseCase;

  LogoutBloc(this._logoutUseCase) : super(LogoutInitial()) {
    on<LogoutRequested>((event, emit) async {
      emit(LogoutInProgress());
      try {
        await _logoutUseCase();
        emit(LogoutSuccess());
      } catch (e) {
        emit(LogoutFailure(e.toString()));
      }
    });
  }
}

