//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/domain/repositories/location_repositories.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:texas_buddy/features/map/domain/entities/user_position.dart';

abstract class LocationRepository {
  /// Retourne un flux continu de la position utilisateur.
  Stream<UserPosition> getPositionStream();

  /// Récupère la dernière position connue (ex: pour initialiser la caméra).
  Future<UserPosition?> getLastKnownPosition();
}