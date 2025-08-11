//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :features/auth/presentation/bloc/login/login_bloc.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';
import 'package:texas_buddy/core/utils/form_status.dart';
import 'package:texas_buddy/features/auth/domain/usecases/login_usecase.dart';
import 'package:texas_buddy/app/router/auth_notifier.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;
  final AuthNotifier _auth;

  LoginBloc(this._loginUseCase,this._auth) : super(const LoginState()) {

    bool _isFormValid(String email, String password) {
      final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
      final pwdOk = password.length >= 6;
      return emailOk && pwdOk;
    }

    on<LoginEmailChanged>((e, emit) {
      final email = e.email.trim();
      final status = _isFormValid(email, state.password)
          ? FormStatus.valid
          : FormStatus.invalid;
      emit(state.copyWith(email: email, status: status));
    });

    on<LoginPasswordChanged>((e, emit) {
      final pwd = e.password;
      final status = _isFormValid(state.email, pwd)
          ? FormStatus.valid
          : FormStatus.invalid;
      emit(state.copyWith(password: pwd, status: status));
    });

    on<LoginSubmitted>((_, emit) async {
      if (!_isFormValid(state.email, state.password)) return;
      if (state.status != FormStatus.valid) return;

      emit(state.copyWith(status: FormStatus.submissionInProgress));
      try {
        await _loginUseCase(email: state.email, password: state.password);
        _auth.setLoggedIn(); // 👈 annonce au routeur
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

