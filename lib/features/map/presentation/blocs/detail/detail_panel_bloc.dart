//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/blocs/all_events/detail_panel_bloc.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/detail_models.dart';
import '../../../domain/usecases/get_activity_detail.dart';
import '../../../domain/usecases/get_event_detail.dart';


part 'detail_panel_event.dart';
part 'detail_panel_state.dart';


class DetailPanelBloc extends Bloc<DetailPanelEvent, DetailPanelState> {
  final GetActivityDetail getActivity;
  final GetEventDetail getEvent;


  DetailPanelBloc({required this.getActivity, required this.getEvent}) : super(DetailHidden()) {
    on<DetailCloseRequested>((e, emit) => emit(DetailHidden()));


    on<DetailOpenRequested>((e, emit) async {
      emit(DetailLoading(anchor: e.anchor));
      if (e.type == DetailType.activity) {
        final res = e.byPlaceId
            ? await getActivity.byPlace(e.idOrPlaceId)
            : await getActivity.byId(e.idOrPlaceId);
        res.fold(
              (fail) => emit(DetailError(message: fail.message)),
              (entity) => emit(DetailActivityLoaded(entity: entity, anchor: e.anchor)),
        );
      } else {
        final res = e.byPlaceId
            ? await getEvent.byPlace(e.idOrPlaceId)
            : await getEvent.byId(e.idOrPlaceId);
        res.fold(
              (fail) => emit(DetailError(message: fail.message)),
              (entity) => emit(DetailEventLoaded(entity: entity, anchor: e.anchor)),
        );
      }
    });
  }
}