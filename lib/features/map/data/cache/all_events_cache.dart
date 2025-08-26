//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/data/cache/all_events_cache.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'dart:collection';
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';

class _BoundsKey {
  final int zoom;           // bucket
  final int nE6, sE6, eE6, wE6; // lat/lng * 1e6 pour réduire le bruit

  _BoundsKey(double north, double south, double east, double west, int zoom)
      : zoom = zoom,
        nE6 = (north * 1e6).round(),
        sE6 = (south * 1e6).round(),
        eE6 = (east  * 1e6).round(),
        wE6 = (west  * 1e6).round();

  @override
  bool operator ==(Object o) =>
      o is _BoundsKey && o.zoom == zoom && o.nE6 == nE6 && o.sE6 == sE6 && o.eE6 == eE6 && o.wE6 == wE6;

  @override
  int get hashCode => Object.hash(zoom, nE6, sE6, eE6, wE6);
}

class AllEventsCache {
  final _map = HashMap<_BoundsKey, List<NearbyItem>>();

  List<NearbyItem>? get(double north, double south, double east, double west, int zoom) =>
      _map[_BoundsKey(north, south, east, west, zoom)];

  void put(double north, double south, double east, double west, int zoom, List<NearbyItem> items) {
    _map[_BoundsKey(north, south, east, west, zoom)] = items;
  }

  void clear() => _map.clear();
}
