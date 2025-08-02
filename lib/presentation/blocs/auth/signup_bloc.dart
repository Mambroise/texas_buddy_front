//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/blocs/auth/signup_bloc.dart
// Author : Morice
//-------------------------------------------------------------------------

import '../form_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/domain/usecases/auth/verify_registration_usecase.dart';
import 'signup_event.dart';
import 'signup_state.dart';
import 'package:texas_buddy/data/repositories/auth/auth_repositories_impl.dart'; // for AuthException

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final VerifyRegistrationUseCase _verifyRegistration;

  SignupBloc(this._verifyRegistration) : super(const SignupState()) {
    // Update email and validate
    on<RegistrationEmailChanged>((e, emit) {
      final isValid = e.email.contains('@');
      emit(state.copyWith(
        email: e.email,
        status: isValid ? FormStatus.valid : FormStatus.invalid,
        message: null,
      ));
    });

    // Update signUpNumber and validate simple non-empty
    on<RegistrationNumberChanged>((e, emit) {
      final isValid = e.signUpNumber.isNotEmpty;
      emit(state.copyWith(
        signUpNumber: e.signUpNumber,
        status: isValid ? FormStatus.valid : FormStatus.invalid,
        message: null,
      ));
    });

    // Handle form submission
    on<RegistrationSubmitted>((_, emit) async {
      // Only proceed if currently valid
      if (state.status != FormStatus.valid) return;

      emit(state.copyWith(status: FormStatus.submissionInProgress));

      try {
        final msg = await _verifyRegistration(
          email: state.email,
          signUpNumber: state.signUpNumber,
        );
        emit(state.copyWith(
          status: FormStatus.submissionSuccess,
          message: msg,
        ));
      } on AuthException catch (e) {
        emit(state.copyWith(
          status: FormStatus.submissionFailure,
          message: e.message,
        ));
      } catch (e) {
        emit(state.copyWith(
          status: FormStatus.submissionFailure,
          message: 'Unknown error',
        ));
      }
    });
  }
}
