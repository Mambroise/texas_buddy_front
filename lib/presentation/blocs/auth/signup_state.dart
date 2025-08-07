//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/blocs/auth/signup_state.dart
// Author : Morice
//-------------------------------------------------------------------------

import '../form_status.dart';
import 'package:equatable/equatable.dart';

/// State of the signup form.
class SignupState extends Equatable {
  final String email;
  final String signUpNumber;
  final FormStatus status;
  final String? message; // success or error message

  final String verificationCode;
  final FormStatus verificationStatus;

  final String newPassword;
  final String confirmPassword;
  final bool isPasswordValid;
  final bool passwordsMatch;
  final FormStatus passwordSetStatus;

  const SignupState({
    this.email = '',
    this.signUpNumber = '',
    this.status = FormStatus.pure,
    this.message,
    this.verificationCode = '',
    this.verificationStatus = FormStatus.pure,
    this.newPassword = '',
    this.confirmPassword = '',
    this.isPasswordValid = false,
    this.passwordsMatch = false,
    this.passwordSetStatus = FormStatus.pure,
  });

  SignupState copyWith({
    String? email,
    String? signUpNumber,
    FormStatus? status,
    String? message,
    String? verificationCode,
    FormStatus? verificationStatus,
    String? newPassword,
    String? confirmPassword,
    bool? isPasswordValid,
    bool? passwordsMatch,
    FormStatus? passwordSetStatus,
  }) {
    return SignupState(
      email: email ?? this.email,
      signUpNumber: signUpNumber ?? this.signUpNumber,
      status: status ?? this.status,
      message: message ?? this.message,
      verificationCode: verificationCode ?? this.verificationCode,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      passwordsMatch: passwordsMatch ?? this.passwordsMatch,
      passwordSetStatus: passwordSetStatus ?? this.passwordSetStatus,
    );
  }

  @override
  List<Object?> get props => [
    email,
    signUpNumber,
    status,
    message,
    verificationCode,
    verificationStatus,
    newPassword,
    confirmPassword,
    isPasswordValid,
    passwordsMatch,
    passwordSetStatus,
  ];
}
