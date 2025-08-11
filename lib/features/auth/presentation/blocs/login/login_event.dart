//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :features/auth/presentation/bloc/login_event.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEmailChanged extends LoginEvent {
  final String email;
  LoginEmailChanged(this.email);
  @override List<Object?> get props => [email];
}

class LoginPasswordChanged extends LoginEvent {
  final String password;
  LoginPasswordChanged(this.password);
  @override List<Object?> get props => [password];
}

class LoginSubmitted extends LoginEvent {}
