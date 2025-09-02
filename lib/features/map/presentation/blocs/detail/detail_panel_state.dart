//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/blocs/all_events/detail_panel_state.dart
// Author : Morice
//---------------------------------------------------------------------------


part of 'detail_panel_bloc.dart';


sealed class DetailPanelState extends Equatable { const DetailPanelState(); @override List<Object?> get props => []; }


class DetailHidden extends DetailPanelState {}


class DetailLoading extends DetailPanelState { final PanelAnchor? anchor; const DetailLoading({this.anchor}); @override List<Object?> get props => [anchor]; }


class DetailActivityLoaded extends DetailPanelState {
  final ActivityDetailEntity entity; final PanelAnchor? anchor;
  const DetailActivityLoaded({required this.entity, this.anchor});
  @override List<Object?> get props => [entity, anchor];
}


class DetailEventLoaded extends DetailPanelState {
  final EventDetailEntity entity; final PanelAnchor? anchor;
  const DetailEventLoaded({required this.entity, this.anchor});
  @override List<Object?> get props => [entity, anchor];
}


class DetailError extends DetailPanelState { final String message; const DetailError({required this.message}); @override List<Object?> get props => [message]; }