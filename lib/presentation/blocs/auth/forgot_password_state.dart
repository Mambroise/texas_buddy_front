//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/blocs/auth/forgot_password_state.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:equatable/equatable.dart';
import '../form_status.dart';

/// État du formulaire “Mot de passe oublié”
class ForgotPasswordState extends Equatable {
  final String email;
  final FormStatus status;
  final String? message; // success or error

  const ForgotPasswordState({
    this.email = '',
    this.status = FormStatus.pure,
    this.message,
  });

  ForgotPasswordState copyWith({
    String? email,
    FormStatus? status,
    String? message,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      status: status ?? this.status,
      message: message,
    );
  }

  @override
  List<Object?> get props => [email, status, message];
}
