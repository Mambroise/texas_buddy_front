//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/cubits/map_focus_cubit.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum MapFocusSource { user, dallas, tripDay, tripStep }

class MapFocusState extends Equatable {
  final MapFocusSource source;
  final double latitude;
  final double longitude;
  final double zoom;
  final DateTime at;

  const MapFocusState({
    required this.source,
    required this.latitude,
    required this.longitude,
    required this.zoom,
    required this.at,
  });

  @override
  List<Object> get props => [source, latitude, longitude, zoom, at];
}

class MapFocusCubit extends Cubit<MapFocusState?> {
  MapFocusCubit() : super(null);

  MapFocusState _build(
      MapFocusSource src,
      double lat,
      double lng,
      double zoom,
      ) {
    return MapFocusState(
      source: src,
      latitude: lat,
      longitude: lng,
      zoom: zoom,
      at: DateTime.now(),
    );
  }

  void focusUser(double lat, double lng, {double zoom = 14}) =>
      emit(_build(MapFocusSource.user, lat, lng, zoom));

  void focusDallas({double zoom = 12}) =>
      emit(_build(MapFocusSource.dallas, 32.7767, -96.7970, zoom));

  void focusTripDay(double lat, double lng, {double zoom = 14}) =>
      emit(_build(MapFocusSource.tripDay, lat, lng, zoom));

  void focusTripStep(double lat, double lng, {double zoom = 16}) =>
      emit(_build(MapFocusSource.tripStep, lat, lng, zoom));
}

