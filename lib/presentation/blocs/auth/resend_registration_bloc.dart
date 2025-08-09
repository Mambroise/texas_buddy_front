//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/blocs/auth/resend_registration_bloc.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/auth/resend_registration_number_usecase.dart';
import 'resend_registration_event.dart';
import 'resend_registration_state.dart';
import '../form_status.dart';
import 'package:texas_buddy/data/repositories/auth/auth_repositories_impl.dart'; // AuthException

class ResendRegistrationBloc
    extends Bloc<ResendRegistrationEvent, ResendRegistrationState> {
  final ResendRegistrationNumberUseCase _useCase;

  ResendRegistrationBloc(this._useCase)
      : super(const ResendRegistrationState()) {
    on<ResendRegistrationEmailChanged>((e, emit) {
      final valid = e.email.contains('@');
      emit(state.copyWith(
        email: e.email,
        status: valid ? FormStatus.valid : FormStatus.invalid,
        message: null,
      ));
    });

    on<ResendRegistrationSubmitted>((_, emit) async {
      if (state.status != FormStatus.valid) return;
      emit(state.copyWith(status: FormStatus.submissionInProgress));

      try {
        final msg = await _useCase(email: state.email);
        emit(state.copyWith(
          status: FormStatus.submissionSuccess,
          message: msg,
        ));
      } on AuthException catch (e) {
        emit(state.copyWith(
          status: FormStatus.submissionFailure,
          message: e.message,
        ));
      } catch (_) {
        emit(state.copyWith(
          status: FormStatus.submissionFailure,
          message: 'Unknown error',
        ));
      }
    });
  }
}
