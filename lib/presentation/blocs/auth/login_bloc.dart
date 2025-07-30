//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/bloc/auth/login_bloc.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';
import 'package:texas_buddy/domain/usecases/auth/login_usecase.dart';
import 'package:texas_buddy/domain/repositories/auth/auth_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;

  LoginBloc(this._loginUseCase) : super(const LoginState()) {
    on<LoginEmailChanged>((e, emit) {
      final status = e.email.contains('@') ? FormStatus.valid : FormStatus.invalid;
      emit(state.copyWith(email: e.email, status: status));
    });

    on<LoginPasswordChanged>((e, emit) {
      final status = e.password.length >= 6 ? FormStatus.valid : FormStatus.invalid;
      emit(state.copyWith(password: e.password, status: status));
    });

    on<LoginSubmitted>((_, emit) async {
      if (state.status != FormStatus.valid) return;
      emit(state.copyWith(status: FormStatus.submissionInProgress));
      try {
        await _loginUseCase(email: state.email, password: state.password);
        emit(state.copyWith(status: FormStatus.submissionSuccess));
      } catch (e) {
        emit(state.copyWith(
          status: FormStatus.submissionFailure,
          errorMessage: e is Exception ? e.toString() : 'Unknown error',
        ));
      }
    });
  }
}

