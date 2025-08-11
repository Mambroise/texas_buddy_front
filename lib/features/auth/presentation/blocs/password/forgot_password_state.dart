//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/blocs/auth/forgot_password_state.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:equatable/equatable.dart';
import 'package:texas_buddy/core/utils/form_status.dart';

/// État du formulaire “Mot de passe oublié”
class ForgotPasswordState extends Equatable {
  final String email;
  final FormStatus status;
  final String? message;

  final String reset2FACode;
  final FormStatus reset2FAStatus;

  final String newPassword;
  final String confirmPassword;
  final FormStatus passwordStatus;

  final bool lengthOK;
  final bool hasNumber;
  final bool hasSpecial;
  final bool hasUpper;
  final bool hasLetter;
  final bool passwordsMatch;
  final bool isPasswordValid;

  const ForgotPasswordState({
    this.email = '',
    this.status = FormStatus.pure,
    this.message,
    this.reset2FACode = '',
    this.reset2FAStatus = FormStatus.pure,
    this.newPassword = '',
    this.confirmPassword = '',
    this.passwordStatus = FormStatus.pure,
    this.lengthOK = false,
    this.hasNumber = false,
    this.hasSpecial = false,
    this.hasUpper = false,
    this.hasLetter = false,
    this.passwordsMatch = false,
    this.isPasswordValid = false,
  });

  ForgotPasswordState copyWith({
    String? email,
    FormStatus? status,
    String? message,
    String? reset2FACode,
    FormStatus? reset2FAStatus,
    String? newPassword,
    String? confirmPassword,
    FormStatus? passwordStatus,
    bool? lengthOK,
    bool? hasNumber,
    bool? hasSpecial,
    bool? hasUpper,
    bool? hasLetter,
    bool? passwordsMatch,
    bool? isPasswordValid,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      status: status ?? this.status,
      message: message ?? this.message,
      reset2FACode: reset2FACode ?? this.reset2FACode,
      reset2FAStatus: reset2FAStatus ?? this.reset2FAStatus,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      passwordStatus: passwordStatus ?? this.passwordStatus,
      lengthOK: lengthOK ?? this.lengthOK,
      hasNumber: hasNumber ?? this.hasNumber,
      hasSpecial: hasSpecial ?? this.hasSpecial,
      hasUpper: hasUpper ?? this.hasUpper,
      hasLetter: hasLetter ?? this.hasLetter,
      passwordsMatch: passwordsMatch ?? this.passwordsMatch,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
    );
  }

  @override
  List<Object?> get props => [
    email,
    status,
    message,
    reset2FACode,
    reset2FAStatus,
    newPassword,
    confirmPassword,
    passwordStatus,
    lengthOK,
    hasNumber,
    hasSpecial,
    hasUpper,
    hasLetter,
    passwordsMatch,
    isPasswordValid,
  ];
}
