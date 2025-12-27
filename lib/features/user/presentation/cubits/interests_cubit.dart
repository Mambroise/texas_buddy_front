//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :user/presentation/cubits/interests_cubit.dart
// Author : Morice
//-------------------------------------------------------------------------

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:texas_buddy/features/user/domain/entities/interest_category.dart';
import 'package:texas_buddy/features/user/domain/usecases/fetch_interest_categories_usecase.dart';
import 'package:texas_buddy/features/user/domain/usecases/fetch_and_cache_me_usecase.dart';
import 'package:texas_buddy/features/user/domain/usecases/save_user_interests_usecase.dart';


enum InterestsStatus { idle, loading, success, failure }
enum InterestsSaveStatus { idle, saving, success, failure }

class InterestsState extends Equatable {
  final InterestsStatus status;
  final InterestsSaveStatus saveStatus;
  final List<InterestCategory> all;
  final Set<int> selectedIds;
  final String query;

  const InterestsState({
    required this.status,
    required this.saveStatus,
    required this.all,
    required this.selectedIds,
    required this.query,
  });

  factory InterestsState.initial(Set<int> preselected) => InterestsState(
    status: InterestsStatus.idle,
    all: const [],
    selectedIds: preselected,
    query: '',
    saveStatus: InterestsSaveStatus.idle,
  );

// copyWith:
  InterestsState copyWith({
    InterestsStatus? status,
    List<InterestCategory>? all,
    Set<int>? selectedIds,
    String? query,
    InterestsSaveStatus? saveStatus,
  }) => InterestsState(
    status: status ?? this.status,
    all: all ?? this.all,
    selectedIds: selectedIds ?? this.selectedIds,
    query: query ?? this.query,
    saveStatus: saveStatus ?? this.saveStatus,
  );

  @override
  List<Object?> get props => [status, saveStatus, all, selectedIds, query];

}

class InterestsCubit extends Cubit<InterestsState> {

  final FetchInterestCategoriesUseCase _fetch;
  final SaveUserInterestsUseCase _save;
  final FetchAndCacheMeUseCase _fetchMe;


  InterestsCubit({
    required FetchInterestCategoriesUseCase fetch,
    required SaveUserInterestsUseCase save,
    required FetchAndCacheMeUseCase fetchMe,
    Set<int> preselected = const {},
  })  : _fetch = fetch,
        _save = save,
        _fetchMe = fetchMe,
        super(InterestsState.initial(preselected));

  Future<void> load() async {
    if (state.status == InterestsStatus.loading) return;
    if (state.all.isNotEmpty) return; // cache session

    emit(state.copyWith(status: InterestsStatus.loading));
    try {
      final list = await _fetch();
      emit(state.copyWith(status: InterestsStatus.success, all: list));
    } catch (_) {
      emit(state.copyWith(status: InterestsStatus.failure));
    }
  }

  void toggle(int id) {
    final next = {...state.selectedIds};
    if (!next.add(id)) next.remove(id);
    emit(state.copyWith(selectedIds: next));
  }

  Future<void> save() async {
    if (state.saveStatus == InterestsSaveStatus.saving) return;

    final ids = state.selectedIds.toList()..sort();
    emit(state.copyWith(saveStatus: InterestsSaveStatus.saving));

    try {
      await _save(categoryIds: ids);

      // ✅ update cache user (étape 6)
      await _fetchMe();

      emit(state.copyWith(saveStatus: InterestsSaveStatus.success));
    } catch (_) {
      emit(state.copyWith(saveStatus: InterestsSaveStatus.failure));
    }
  }

  void setQuery(String q) => emit(state.copyWith(query: q));
}
