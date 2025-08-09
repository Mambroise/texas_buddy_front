//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/blocs/auth/signup_event.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// User has changed the email field.
class RegistrationEmailChanged extends SignupEvent {
  final String email;
  RegistrationEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

/// User has changed the registration number field.
class RegistrationNumberChanged extends SignupEvent {
  final String signUpNumber;
  RegistrationNumberChanged(this.signUpNumber);

  @override
  List<Object?> get props => [signUpNumber];
}

/// User tapped “Verify & Signup”
class RegistrationSubmitted extends SignupEvent {}

/// User typed 2FA code
class Registration2FACodeChanged extends SignupEvent {
  final String code;
  Registration2FACodeChanged(this.code);

  @override
  List<Object?> get props => [code];
}

/// User tapped submit after typing code
class VerifyRegistration2FACodeSubmitted extends SignupEvent {
  final String code;
  VerifyRegistration2FACodeSubmitted(this.code);

  @override
  List<Object?> get props => [code];
}

/// User changed new password
class RegistrationPasswordChanged extends SignupEvent {
  final String password;
  RegistrationPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

/// User confirmed password
class RegistrationConfirmPasswordChanged extends SignupEvent {
  final String password;
  RegistrationConfirmPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

/// User tapped Submit to set password
class RegistrationSetPasswordSubmitted extends SignupEvent {}

class RegistrationPasswordStateCleared extends SignupEvent {}
