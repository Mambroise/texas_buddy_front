//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/blocs/nearby/nearby_state.dart
// Author : Morice
//---------------------------------------------------------------------------


part of 'nearby_bloc.dart';

enum NearbyStatus { initial, loading, loaded, error }

class NearbyState extends Equatable {
  final NearbyStatus status;
  final List<NearbyItem> items;
  final String? error;

  const NearbyState({
    required this.status,
    required this.items,
    this.error,
  });

  const NearbyState.initial()
      : status = NearbyStatus.initial,
        items = const [],
        error = null;

  NearbyState copyWith({
    NearbyStatus? status,
    List<NearbyItem>? items,
    String? error,
  }) {
    return NearbyState(
      status: status ?? this.status,
      items: items ?? this.items,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, items, error];
}
