//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/presentation/cubits/user_overview_cubit.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/features/user/domain/entities/user_profile.dart';
import 'package:texas_buddy/features/user/domain/usecases/get_cached_user_usecase.dart';
import 'package:texas_buddy/features/user/domain/usecases/fetch_and_cache_me_usecase.dart';

class UserOverviewState extends Equatable {
  final bool loading;
  final UserProfile? user;
  final String? error;

  const UserOverviewState({this.loading = false, this.user, this.error});

  UserOverviewState copyWith({bool? loading, UserProfile? user, String? error}) =>
      UserOverviewState(loading: loading ?? this.loading, user: user ?? this.user, error: error);

  @override
  List<Object?> get props => [loading, user, error];
}

class UserOverviewCubit extends Cubit<UserOverviewState> {
  final GetCachedUserUseCase getCached;
  final FetchAndCacheMeUseCase refreshRemote;

  UserOverviewCubit({required this.getCached, required this.refreshRemote})
      : super(const UserOverviewState());

  Future<void> loadCached() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final u = await getCached();
      emit(UserOverviewState(loading: false, user: u));
    } catch (e) {
      emit(UserOverviewState(loading: false, error: e.toString()));
    }
  }

  Future<void> refresh() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final u = await refreshRemote();
      emit(UserOverviewState(loading: false, user: u));
    } catch (e) {
      emit(UserOverviewState(loading: false, error: e.toString()));
    }
  }
}
