//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :features/auth/presentation/blocs/login_state.dart
// Author : Morice
//-------------------------------------------------------------------------

import 'package:texas_buddy/core/utils/form_status.dart';
import 'package:equatable/equatable.dart';


class LoginState extends Equatable {
  final String email;
  final String password;
  final FormStatus status;
  final String? errorMessage;

  const LoginState({
    this.email = '',
    this.password = '',
    this.status = FormStatus.pure,
    this.errorMessage,
  });

  LoginState copyWith({
    String? email,
    String? password,
    FormStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override List<Object?> get props => [email, password, status, errorMessage];
}
