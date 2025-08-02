//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/blocs/auth/signup_state.dart
// Author : Morice
//-------------------------------------------------------------------------

import '../form_status.dart';
import 'package:equatable/equatable.dart';


/// State of the signup form.
class SignupState extends Equatable {
  final String email;
  final String signUpNumber;
  final FormStatus status;
  final String? message; // success or error message

  const SignupState({
    this.email = '',
    this.signUpNumber = '',
    this.status = FormStatus.pure,
    this.message,
  });

  SignupState copyWith({
    String? email,
    String? signUpNumber,
    FormStatus? status,
    String? message,
  }) {
    return SignupState(
      email: email ?? this.email,
      signUpNumber: signUpNumber ?? this.signUpNumber,
      status: status ?? this.status,
      message: message,
    );
  }

  @override
  List<Object?> get props => [email, signUpNumber, status, message];
}
