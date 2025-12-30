//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/blocs/all_events/detail_panel_state.dart
// Author : Morice
//---------------------------------------------------------------------------

part of 'detail_panel_bloc.dart';

class TravelInfo extends Equatable {
  final int minutes;
  final int meters;

  const TravelInfo({
    required this.minutes,
    required this.meters,
  });

  @override
  List<Object> get props => [minutes, meters];
}

sealed class DetailPanelState extends Equatable {
  const DetailPanelState();

  @override
  List<Object?> get props => [];
}

class DetailHidden extends DetailPanelState {
  const DetailHidden();
}

class DetailLoading extends DetailPanelState {
  final double? anchor; // tu avais déjà "anchor" dans l’event, on le garde
  const DetailLoading({this.anchor});

  @override
  List<Object?> get props => [anchor];
}

class DetailError extends DetailPanelState {
  final String message;
  const DetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

class DetailActivityLoaded extends DetailPanelState {
  final ActivityDetailEntity entity;

  /// ✅ NEW
  final TravelInfo? travel;
  final MapFocusSource? focusSource;

  /// UI
  final double? anchor;

  const DetailActivityLoaded({
    required this.entity,
    this.travel,
    this.focusSource,
    this.anchor,
  });

  @override
  List<Object?> get props => [entity, travel, focusSource, anchor];
}

class DetailEventLoaded extends DetailPanelState {
  final EventDetailEntity entity;

  /// ✅ NEW
  final TravelInfo? travel;
  final MapFocusSource? focusSource;

  /// UI
  final double? anchor;

  const DetailEventLoaded({
    required this.entity,
    this.travel,
    this.focusSource,
    this.anchor,
  });

  @override
  List<Object?> get props => [entity, travel, focusSource, anchor];
}
