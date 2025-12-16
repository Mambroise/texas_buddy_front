//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/domain/repositories/travel_repository.dart
// Author : Morice
//---------------------------------------------------------------------------


abstract class TravelRepository {
  /// Retourne (minutes, meters) pour un trajet origin → destination.
  Future<(int minutes, int meters)> estimate({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String mode,
    String? lang, // ex: "fr" ; optionnel
  });
}
