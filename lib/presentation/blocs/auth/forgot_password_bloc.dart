//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/blocs/auth/forgot_password_bloc.dart
// Author : Morice
//-------------------------------------------------------------------------

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/auth/request_password_reset_usecase.dart';
import '../../../domain/usecases/auth/set_password_usecase.dart';
import '../../../domain/usecases/auth/verify_reset_pwd_2fa_usecase.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';
import '../form_status.dart';
import 'package:texas_buddy/data/repositories/auth/auth_repositories_impl.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final RequestPasswordResetUseCase _requestReset;
  final VerifyResetPwd2FACodeUseCase _verifyResetPwd2FACode;
  final SetPasswordUseCase _setPasswordUseCase;

  ForgotPasswordBloc(
      this._requestReset,
      this._verifyResetPwd2FACode,
      this._setPasswordUseCase,
      ) : super(ForgotPasswordState()) {

    // Handle email input change
    on<ForgotPasswordEmailChanged>((e, emit) {
      final valid = e.email.contains('@');
      emit(state.copyWith(
        email: e.email,
        status: valid ? FormStatus.valid : FormStatus.invalid,
        message: null,
      ));
    });

    // Handle submission of reset password request
    on<ForgotPasswordSubmitted>((_, emit) async {
      if (state.status != FormStatus.valid) return;
      emit(state.copyWith(status: FormStatus.submissionInProgress));

      try {
        final msg = await _requestReset(email: state.email);
        emit(state.copyWith(
          status: FormStatus.submissionSuccess,
          message: msg,
        ));
      } on AuthException catch (e) {
        emit(state.copyWith(
          status: FormStatus.submissionFailure,
          message: e.message,
        ));
      } catch (_) {
        emit(state.copyWith(
          status: FormStatus.submissionFailure,
          message: 'Unknown error',
        ));
      }
    });

    // Handle code input
    on<ResetPassword2FACodeChanged>((event, emit) {
      emit(state.copyWith(reset2FACode: event.code));
    });

    // Handle code verification submission
    on<ResetPassword2FACodeSubmitted>((event, emit) async {
      emit(state.copyWith(reset2FAStatus: FormStatus.submissionInProgress));
      try {
        final message = await _verifyResetPwd2FACode(
          email: state.email,
          code: state.reset2FACode,
        );
        emit(state.copyWith(reset2FAStatus: FormStatus.submissionSuccess, message: message));
      } catch (e) {
        emit(state.copyWith(reset2FAStatus: FormStatus.submissionFailure, message: e.toString()));
      }
    });

    // Reset full state
    on<ForgotPasswordResetStateCleared>((event, emit) {
      emit(state.copyWith(
        status: FormStatus.pure,
        reset2FAStatus: FormStatus.pure,
        message: null,
        reset2FACode: '',
      ));
    });

    // Handle password change and update criteria validation
    on<NewPasswordChanged>((event, emit) {
      final pwd = event.password;
      final hasNumber = RegExp(r'[0-9]').hasMatch(pwd);
      final hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(pwd);
      final hasUpper = RegExp(r'[A-Z]').hasMatch(pwd);
      final hasLetter = RegExp(r'[A-Za-z]').hasMatch(pwd);
      final lengthOK = pwd.length >= 8;
      final passwordsMatch = pwd == state.confirmPassword;

      emit(state.copyWith(
        newPassword: pwd,
        hasNumber: hasNumber,
        hasSpecial: hasSpecial,
        hasUpper: hasUpper,
        hasLetter: hasLetter,
        lengthOK: lengthOK,
        passwordsMatch: passwordsMatch,
        isPasswordValid: lengthOK && hasNumber && hasSpecial && hasUpper && hasLetter && passwordsMatch,
      ));
    });

    // Handle confirm password input
    on<ConfirmPasswordChanged>((event, emit) {
      final match = event.password == state.newPassword;
      emit(state.copyWith(
        confirmPassword: event.password,
        passwordsMatch: match,
        isPasswordValid: state.isPasswordValid && match,
      ));
    });

    // Handle final new password submission
    on<NewPasswordSubmitted>((event, emit) async {
      emit(state.copyWith(status: FormStatus.submissionInProgress));
      try {
        await _setPasswordUseCase(
          password: state.newPassword,
          confirmPassword: state.confirmPassword,
        );
        emit(state.copyWith(
          status: FormStatus.submissionSuccess,
          message: "Password updated successfully.",
        ));

      } catch (e) {
        emit(state.copyWith(
          status: FormStatus.submissionFailure,
          message: e.toString(),
        ));
      }
    });
  }
}
