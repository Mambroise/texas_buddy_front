//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/data/datasources/location_datasource.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:geolocator/geolocator.dart';
import 'package:texas_buddy/features/map/domain/entities/user_position.dart';

abstract class LocationDataSource {
  Stream<UserPosition> positionStream();
  Future<UserPosition?> getLastKnown();
}

class LocationDataSourceImpl implements LocationDataSource {
  @override
  Stream<UserPosition> positionStream() async* {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Le service de localisation est désactivé.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permission localisation refusée (définitif).');
    }

    // Optionnel : pousser la dernière position connue immédiatement
    final last = await Geolocator.getLastKnownPosition();
    if (last != null) {
      yield UserPosition(latitude: last.latitude, longitude: last.longitude);
    }

    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // évite le spam
      ),
    ).map((pos) => UserPosition(latitude: pos.latitude, longitude: pos.longitude));
  }

  @override
  Future<UserPosition?> getLastKnown() async {
    final pos = await Geolocator.getLastKnownPosition();
    return (pos == null) ? null
        : UserPosition(latitude: pos.latitude, longitude: pos.longitude);
  }
}
