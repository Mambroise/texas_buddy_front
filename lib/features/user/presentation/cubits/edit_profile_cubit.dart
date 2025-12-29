//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/presentation/cubits/edit_profile_cubit.dart
// Author : Morice
//-------------------------------------------------------------------------

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:texas_buddy/features/user/domain/entities/user_profile.dart';
import 'package:texas_buddy/features/user/domain/usecases/update_me_usecase.dart';

enum EditProfileStatus { idle, saving, success, failure }

class EditProfileState extends Equatable {
  final EditProfileStatus status;
  final String? error;
  final UserProfile? user;

  const EditProfileState({
    required this.status,
    this.error,
    this.user,
  });

  factory EditProfileState.initial() => const EditProfileState(status: EditProfileStatus.idle);

  EditProfileState copyWith({
    EditProfileStatus? status,
    String? error,
    UserProfile? user,
  }) =>
      EditProfileState(
        status: status ?? this.status,
        error: error,
        user: user ?? this.user,
      );

  @override
  List<Object?> get props => [status, error, user];
}

class EditProfileCubit extends Cubit<EditProfileState> {
  final UpdateMeUseCase _updateMe;

  EditProfileCubit({required UpdateMeUseCase updateMe})
      : _updateMe = updateMe,
        super(EditProfileState.initial());

  Future<void> save({
    required String email,
    required String address,
    required String phone,
    required String country,
  }) async {
    if (state.status == EditProfileStatus.saving) return;

    emit(state.copyWith(status: EditProfileStatus.saving, error: null));
    try {
      final u = await _updateMe(
        email: email,
        address: address,
        phone: phone,
        country: country,
      );
      emit(state.copyWith(status: EditProfileStatus.success, user: u));
    } catch (e) {
      emit(state.copyWith(status: EditProfileStatus.failure, error: e.toString()));
    }
  }
}
