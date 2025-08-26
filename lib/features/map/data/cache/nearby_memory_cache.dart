//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/data/cache/nearby_memory_cache.dart
// Author : Morice
//---------------------------------------------------------------------------


// Simple in-memory cache with TTL for nearby items.
// Keyed by a quantized bounds+zoom "tile".
// Categories are NOT part of the key (we filter on UI immediately).

import '../../domain/entities/nearby_item.dart';

class NearbyMemoryCache {
  NearbyMemoryCache({this.ttl = const Duration(minutes: 2)});

  final Duration ttl;
  final Map<String, _Entry> _store = <String, _Entry>{};

  // Quantize ~0.05° (≈5–6 km) to reuse entries on small pans.
  String makeKey({
    required double north,
    required double east,
    required double south,
    required double west,
    required int zoom,
  }) {
    double q(double v) => (v / 0.05).roundToDouble() * 0.05;
    final n = q(north), e = q(east), s = q(south), w = q(west);
    return 'z$zoom|$n,$e,$s,$w';
  }

  List<NearbyItem>? getFresh(String key) {
    final e = _store[key];
    if (e == null) return null;
    if (DateTime.now().difference(e.storedAt) > ttl) {
      _store.remove(key);
      return null;
    }
    return e.items;
  }

  void put(String key, List<NearbyItem> items) {
    _store[key] = _Entry(items: items, storedAt: DateTime.now());
  }

  void clear() => _store.clear();
}

class _Entry {
  final List<NearbyItem> items;
  final DateTime storedAt;
  _Entry({required this.items, required this.storedAt});
}
