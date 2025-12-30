//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/blocs/all_events/detail_panel_event.dart
// Author : Morice
//---------------------------------------------------------------------------

part of 'detail_panel_bloc.dart';

enum DetailType { activity, event }

sealed class DetailPanelEvent extends Equatable {
  const DetailPanelEvent();

  @override
  List<Object?> get props => [];
}

class DetailCloseRequested extends DetailPanelEvent {
  const DetailCloseRequested();
}

class DetailOpenRequested extends DetailPanelEvent {
  final DetailType type;
  final String idOrPlaceId;
  final bool byPlaceId;

  /// UI anchor (si tu l’utilises)
  final double? anchor;

  /// ✅ NEW: langue ("fr"/"en"/"es") transmise au backend travel
  final String? lang;

  const DetailOpenRequested({
    required this.type,
    required this.idOrPlaceId,
    required this.byPlaceId,
    this.anchor,
    this.lang,
  });

  @override
  List<Object?> get props => [type, idOrPlaceId, byPlaceId, anchor, lang];
}
