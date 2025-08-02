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
