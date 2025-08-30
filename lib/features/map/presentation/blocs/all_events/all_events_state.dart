//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/blocs/all_events/all_events_state.dart
// Author : Morice
//---------------------------------------------------------------------------


part of 'all_events_bloc.dart';

enum AllEventsStatus { idle, loading, ready, error }

class AllEventsState extends Equatable {
  final AllEventsStatus status;
  final List<NearbyItem> items;
  final String? error;

  const AllEventsState({
    this.status = AllEventsStatus.idle,
    this.items = const [],
    this.error,
  });

  AllEventsState copyWith({
    AllEventsStatus? status,
    List<NearbyItem>? items,
    String? error,
  }) =>
      AllEventsState(
        status: status ?? this.status,
        items: items ?? this.items,
        error: error,
      );

  @override
  List<Object?> get props => [status, items, error];
}
