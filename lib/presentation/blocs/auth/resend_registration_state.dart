//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/blocs/auth/resend_registration_state.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:equatable/equatable.dart';
import '../form_status.dart';

/// State of the "forgot registration" form.
class ResendRegistrationState extends Equatable {
  final String email;
  final FormStatus status;
  final String? message;

  const ResendRegistrationState({
    this.email = '',
    this.status = FormStatus.pure,
    this.message,
  });

  ResendRegistrationState copyWith({
    String? email,
    FormStatus? status,
    String? message,
  }) {
    return ResendRegistrationState(
      email: email ?? this.email,
      status: status ?? this.status,
      message: message,
    );
  }

  @override List<Object?> get props => [email, status, message];
}
