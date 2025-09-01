//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/blocs/all_events/detail_panel_event.dart
// Author : Morice
//---------------------------------------------------------------------------


part of 'detail_panel_bloc.dart';


enum DetailType { activity, event }


/// Anchor used to position the card near marker/label if needed
class PanelAnchor extends Equatable {
  final double? screenDx; // screen x in px
  final double? screenDy; // screen y in px
  const PanelAnchor({this.screenDx, this.screenDy});
  @override
  List<Object?> get props => [screenDx, screenDy];
}


sealed class DetailPanelEvent extends Equatable { const DetailPanelEvent(); @override List<Object?> get props => []; }

class DetailOpenRequested extends DetailPanelEvent {
  final DetailType type;
  final String idOrPlaceId;
  final bool byPlaceId;
  final PanelAnchor? anchor; // Optionally pass marker screen point
  const DetailOpenRequested({required this.type, required this.idOrPlaceId, this.byPlaceId=false, this.anchor});
}


class DetailCloseRequested extends DetailPanelEvent { const DetailCloseRequested(); }