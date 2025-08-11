//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/blocs/auth/signup_state.dart
// Author : Morice
//-------------------------------------------------------------------------


part of 'logout_bloc.dart';

abstract class LogoutState extends Equatable {
  const LogoutState();

  @override
  List<Object?> get props => [];
}

class LogoutInitial extends LogoutState {}

class LogoutInProgress extends LogoutState {}

class LogoutSuccess extends LogoutState {}

class LogoutFailure extends LogoutState {
  final String error;
  const LogoutFailure(this.error);

  @override
  List<Object?> get props => [error];
}
