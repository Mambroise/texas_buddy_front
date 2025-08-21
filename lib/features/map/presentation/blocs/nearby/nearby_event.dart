//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/blocs/nearby/nearby_event.dart
// Author : Morice
//---------------------------------------------------------------------------


part of 'nearby_bloc.dart';

abstract class NearbyEvent extends Equatable {
  const NearbyEvent();
  @override
  List<Object?> get props => [];
}

class NearbyRequested extends NearbyEvent {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final int limit;
  const NearbyRequested({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 25,
    this.limit = 100,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusKm, limit];

}

class NearbyRequestedBounds extends NearbyEvent {
  final double north;
  final double south;
  final double east;
  final double west;
  final int zoom;
  final List<String> categoryKeys;
  final int limit;
  final double? centerLat;
  final double? centerLng;

  const NearbyRequestedBounds({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
    required this.zoom,
    this.categoryKeys = const [],
    this.limit = 150,
    this.centerLat,
    this.centerLng,
  });

  @override
  List<Object?> get props =>
      [north, south, east, west, zoom, categoryKeys, limit, centerLat, centerLng];
}
