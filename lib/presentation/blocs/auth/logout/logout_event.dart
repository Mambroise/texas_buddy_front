//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/blocs/auth/logout_event.dart
// Author : Morice
//-------------------------------------------------------------------------


part of 'logout_bloc.dart';

abstract class LogoutEvent extends Equatable {
  const LogoutEvent();

  @override
  List<Object> get props => [];
}

class LogoutRequested extends LogoutEvent {}
