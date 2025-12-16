//---------------------------------------------------------------------------
// File   : features/map/presentation/cubits/map_focus_cubit.dart
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

  // ⬇️ nouvelle fenêtre anti-"vol de focus" pour TripDay
  DateTime? _tripDaySuppressedUntil;
  static const _kTripStepHold = Duration(milliseconds: 700); // ajuste si besoin

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

  bool _tripDaySuppressedNow() {
    final until = _tripDaySuppressedUntil;
    if (until == null) return false;
    return DateTime.now().isBefore(until);
  }

  // 🔒 Optionnel : visible pour l’UI (utile si tu veux consulter l’état)
  bool get isTripDaySuppressed => _tripDaySuppressedNow();

  // --- API publique -------------------------------------------------------

  void focusUser(double lat, double lng, {double zoom = 14}) {
    emit(_build(MapFocusSource.user, lat, lng, zoom));
  }

  void focusDallas({double zoom = 12}) {
    emit(_build(MapFocusSource.dallas, 32.7767, -96.7970, zoom));
  }

  // ⛔ bloque si la fenêtre de suppression TripDay est active
  void focusTripDay(double lat, double lng, {double zoom = 14}) {
    if (_tripDaySuppressedNow()) {
      return; // on ignore poliment
    }
    emit(_build(MapFocusSource.tripDay, lat, lng, zoom));
  }

  // ✅ pose un "hold" explicite sur les prochains focusTripDay
  void focusTripStep(double lat, double lng, {double zoom = 16}) {
    _tripDaySuppressedUntil = DateTime.now().add(_kTripStepHold);
    emit(_build(MapFocusSource.tripStep, lat, lng, zoom));
  }
}
