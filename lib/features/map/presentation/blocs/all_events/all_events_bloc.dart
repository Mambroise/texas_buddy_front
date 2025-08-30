//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/blocs/all_events/all_events_bloc.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';
import 'package:texas_buddy/features/map/domain/usecases/get_all_events_in_bounds.dart';

part 'all_events_event.dart';
part 'all_events_state.dart';

class AllEventsBloc extends Bloc<AllEventsEvent, AllEventsState> {
  final GetAllEventsInBounds getAllEventsInBounds;

  AllEventsBloc({required this.getAllEventsInBounds})
      : super(const AllEventsState()) {
    on<AllEventsLoadInBounds>(_onLoadInBounds);
  }

  Future<void> _onLoadInBounds(
      AllEventsLoadInBounds e, Emitter<AllEventsState> emit) async {
    emit(state.copyWith(status: AllEventsStatus.loading));
    try {
      final items = await getAllEventsInBounds(
        north: e.north,
        south: e.south,
        east: e.east,
        west: e.west,
        zoom: e.zoom,
        year: e.year,
        useCache: e.useCache,
        localeHeader: e.localeHeader,
      );
      emit(state.copyWith(status: AllEventsStatus.ready, items: items));
    } catch (err) {
      emit(state.copyWith(status: AllEventsStatus.error, error: err.toString()));
    }
  }
}
