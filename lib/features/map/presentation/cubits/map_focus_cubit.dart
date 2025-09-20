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

  const MapFocusState({
    required this.source,
    required this.latitude,
    required this.longitude,
    required this.zoom,
  });

  @override
  List<Object> get props => [source, latitude, longitude, zoom];
}

class MapFocusCubit extends Cubit<MapFocusState?> {
  MapFocusCubit() : super(null);

  void focusUser(double lat, double lng, {double zoom = 14}) =>
      emit(MapFocusState(source: MapFocusSource.user, latitude: lat, longitude: lng, zoom: zoom));

  void focusDallas({double zoom = 12}) =>
      emit(const MapFocusState(source: MapFocusSource.dallas, latitude: 32.7767, longitude: -96.7970, zoom: 12));

  void focusTripDay(double lat, double lng, {double zoom = 14}) =>
      emit(MapFocusState(source: MapFocusSource.tripDay, latitude: lat, longitude: lng, zoom: zoom));

  void focusTripStep(double lat, double lng, {double zoom = 16}) =>
      emit(MapFocusState(source: MapFocusSource.tripStep, latitude: lat, longitude: lng, zoom: zoom));
}
