//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/blocs/auth/resend_registration_event.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:equatable/equatable.dart';

abstract class ResendRegistrationEvent extends Equatable {
  @override List<Object?> get props => [];
}

/// User updated the email field for resend.
class ResendRegistrationEmailChanged extends ResendRegistrationEvent {
  final String email;
  ResendRegistrationEmailChanged(this.email);
  @override List<Object?> get props => [email];
}

/// User tapped “Send registration number”.
class ResendRegistrationSubmitted extends ResendRegistrationEvent {}
