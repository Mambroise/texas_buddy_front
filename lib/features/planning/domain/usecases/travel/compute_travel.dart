//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/usecases/trips/create_trip.dart
// Author : Morice origin/destination (+mode/lang) -> (minutes, meters)
//---------------------------------------------------------------------------


import '../../repositories/travel_repository.dart';

class ComputeTravel {
  final TravelRepository _repo;
  const ComputeTravel(this._repo);

  /// Calcule la durée (min) et la distance (m) entre deux points.
  ///
  /// [mode] par défaut "driving".
  /// [lang] optionnel (ex. "fr"), transmis jusqu'au backend pour libellés Google.
  Future<(int minutes, int meters)> call({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String mode = 'driving',
    String? lang,
  }) {
    return _repo.estimate(
      originLat: originLat,
      originLng: originLng,
      destLat: destLat,
      destLng: destLng,
      mode: mode,
      lang: lang,
    );
  }
}
