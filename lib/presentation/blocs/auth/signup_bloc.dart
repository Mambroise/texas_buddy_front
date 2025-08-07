//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/blocs/auth/signup_bloc.dart
// Author : Morice
//-------------------------------------------------------------------------

import '../form_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/domain/usecases/auth/verify_registration_usecase.dart';
import 'package:texas_buddy/domain/usecases/auth/verify_registration_2fa_usecase.dart';
import 'package:texas_buddy/domain/usecases/auth/set_password_registration_usecase.dart';
import 'signup_event.dart';
import 'signup_state.dart';
import 'package:texas_buddy/data/repositories/auth/auth_repositories_impl.dart'; // for AuthException

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final VerifyRegistrationUseCase _verifyRegistration;
  final VerifyRegistration2FACodeUseCase _verify2FA;
  final SetPasswordForRegistrationUseCase _setInitialPassword;

  SignupBloc(
      this._verifyRegistration,
      this._verify2FA,
      this._setInitialPassword,
      ) : super(const SignupState()) {
    on<RegistrationEmailChanged>((e, emit) {
      final isValid = e.email.contains('@');
      emit(state.copyWith(
        email: e.email,
        status: isValid ? FormStatus.valid : FormStatus.invalid,
        message: null,
      ));
    });

    on<RegistrationNumberChanged>((e, emit) {
      final isValid = e.signUpNumber.isNotEmpty;
      emit(state.copyWith(
        signUpNumber: e.signUpNumber,
        status: isValid ? FormStatus.valid : FormStatus.invalid,
        message: null,
      ));
    });

    on<VerifyRegistration2FACodeSubmitted>((event, emit) async {
      emit(state.copyWith(verificationStatus: FormStatus.submissionInProgress));

      try {
        final msg = await _verify2FA(
          email: state.email,
          code: event.code,
        );

        emit(state.copyWith(
          verificationStatus: FormStatus.submissionSuccess,
          message: msg,
        ));
      } on AuthException catch (e) {
        emit(state.copyWith(
          verificationStatus: FormStatus.submissionFailure,
          message: e.message,
        ));
      } catch (e) {
        emit(state.copyWith(
          verificationStatus: FormStatus.submissionFailure,
          message: '2FA failed',
        ));
      }
    });

    on<Registration2FACodeChanged>((event, emit) {
      emit(state.copyWith(verificationCode: event.code));
    });

    on<RegistrationPasswordChanged>((event, emit) {
      final pwd = event.password;
      emit(state.copyWith(
        newPassword: pwd,
        isPasswordValid: _isValid(pwd),
        passwordsMatch: pwd == state.confirmPassword,
      ));
    });

    on<RegistrationConfirmPasswordChanged>((event, emit) {
      final confirmPwd = event.password;
      emit(state.copyWith(
        confirmPassword: confirmPwd,
        passwordsMatch: confirmPwd == state.newPassword,
      ));
    });

    // Reset full state
    on<RegistrationPasswordStateCleared>((event, emit) {
      emit(state.copyWith(
        status: FormStatus.pure,
        verificationStatus: FormStatus.pure,
        message: null,
        verificationCode: '',
      ));
    });

    on<RegistrationSetPasswordSubmitted>((event, emit) async {
      emit(state.copyWith(passwordSetStatus: FormStatus.submissionInProgress));

      try {
        await _setInitialPassword(
          email: state.email,
          password: state.newPassword,
        );

        emit(state.copyWith(
          passwordSetStatus: FormStatus.submissionSuccess,
          message: "Password successfully set.",
        ));
      } on AuthException catch (e) {
        emit(state.copyWith(
          passwordSetStatus: FormStatus.submissionFailure,
          message: e.message,
        ));
      } catch (_) {
        emit(state.copyWith(
          passwordSetStatus: FormStatus.submissionFailure,
          message: 'Unknown error',
        ));
      }
    });

    on<RegistrationSubmitted>((_, emit) async {
      if (state.status != FormStatus.valid) return;
      emit(state.copyWith(status: FormStatus.submissionInProgress));

      try {
        final msg = await _verifyRegistration(
          email: state.email,
          signUpNumber: state.signUpNumber,
        );

        emit(state.copyWith(
          status: FormStatus.submissionSuccess,
          message: msg,
        ));
      } on AuthException catch (e) {
        emit(state.copyWith(
          status: FormStatus.submissionFailure,
          message: e.message,
        ));
      } catch (e) {
        emit(state.copyWith(
          status: FormStatus.submissionFailure,
          message: 'Unknown error',
        ));
      }
    });
  }

  bool _isValid(String pwd) {
    return pwd.length >= 8 &&
        RegExp(r'[0-9]').hasMatch(pwd) &&
        RegExp(r'[!@#\\$%^&*(),.?":{}|<>]').hasMatch(pwd) &&
        RegExp(r'[A-Z]').hasMatch(pwd) &&
        RegExp(r'[A-Za-z]').hasMatch(pwd);
  }
}
