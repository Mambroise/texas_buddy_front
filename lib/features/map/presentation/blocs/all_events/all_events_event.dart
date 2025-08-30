//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/blocs/all_events/all_events_event.dart
// Author : Morice
//---------------------------------------------------------------------------


part of 'all_events_bloc.dart';

abstract class AllEventsEvent extends Equatable {
  const AllEventsEvent();
  @override
  List<Object?> get props => [];
}

class AllEventsLoadInBounds extends AllEventsEvent {
  final double north, south, east, west;
  final int zoom;
  final int? year;
  final bool useCache;
  final String? localeHeader;

  const AllEventsLoadInBounds({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
    required this.zoom,
    this.year,
    this.useCache = true,
    this.localeHeader,
  });

  @override
  List<Object?> get props => [north, south, east, west, zoom, year, useCache, localeHeader];
}
