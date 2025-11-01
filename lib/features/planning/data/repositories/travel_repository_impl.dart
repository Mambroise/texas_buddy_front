//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : data/repositories/travel_repository_impl.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'dart:collection';
import '../../domain/repositories/travel_repository.dart';
import '../datasources/remote/travel_remote_datasource.dart';

class TravelRepositoryImpl implements TravelRepository {
  final TravelRemoteDatasource remote;
  TravelRepositoryImpl(this.remote);

  // Petit cache mémoire (clé normalisée, LRU soft)
  static const int _maxEntries = 200;
  final _cache = LinkedHashMap<String, (int,int)>();

  String _k(double a, double b, double c, double d, String m, String? lang) {
    String f(double x) => x.toStringAsFixed(5);
    return '${f(a)},${f(b)}|${f(c)},${f(d)}|$m|${lang ?? ''}';
  }

  void _touch(String key, (int,int) val) {
    // LinkedHashMap n'a pas LRU nativement → réinsère pour “toucher”
    _cache.remove(key);
    _cache[key] = val;
    if (_cache.length > _maxEntries) {
      _cache.remove(_cache.keys.first);
    }
  }

  @override
  Future<(int minutes, int meters)> estimate({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String mode = 'driving',
    String? lang,
  }) async {
    final key = _k(originLat, originLng, destLat, destLng, mode, lang);

    final hit = _cache[key];
    if (hit != null) {
      _touch(key, hit);
      return hit;
    }

    final res = await remote.estimate(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
      mode: mode,
      lang: lang,
    );

    _touch(key, res);
    return res;
  }
}
