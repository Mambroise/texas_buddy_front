//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/blocs/auth/forgot_password_event.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// L’utilisateur a saisi / modifié son email.
class ForgotPasswordEmailChanged extends ForgotPasswordEvent {
  final String email;
  ForgotPasswordEmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

/// L’utilisateur a cliqué sur “Send reset code”.
class ForgotPasswordSubmitted extends ForgotPasswordEvent {}

class ResetPassword2FACodeChanged extends ForgotPasswordEvent {
  final String code;
  ResetPassword2FACodeChanged(this.code);
}

class ResetPassword2FACodeSubmitted extends ForgotPasswordEvent {}

class ForgotPasswordResetStateCleared extends ForgotPasswordEvent {}


/// user clicked on “Send new password”.
class NewPasswordChanged extends ForgotPasswordEvent {
  final String password;
  NewPasswordChanged(this.password);
}

class ConfirmPasswordChanged extends ForgotPasswordEvent {
  final String password;
  ConfirmPasswordChanged(this.password);
}

class NewPasswordSubmitted extends ForgotPasswordEvent {}
