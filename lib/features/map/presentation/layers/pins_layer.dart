//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/layers/pins_layer.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/nearby_item.dart';

/// Hue "Texas blue" pour les activities.
const double kTexasBlueHue = 225.0;

/// Id stable pour un item → utilisé pour MarkerId.
String baseIdFor(NearbyItem it) => '${it.kind.name}_${it.id}';

double _hueFor(NearbyItem it) {
  // Préfère l’enum NearbyKind si dispo.
  if (it.kind.name == 'event') return BitmapDescriptor.hueRed;
  // Par défaut: bleu Texas (activities).
  return kTexasBlueHue;
}

/// Construit UNIQUEMENT les pins Google (sans labels).
/// - `onTap` permet à la page d'appliquer le même comportement qu'avant.
Map<MarkerId, Marker> buildGooglePins({
  required List<NearbyItem> items,
  required Future<void> Function(NearbyItem it) onTap,
}) {
  final map = <MarkerId, Marker>{};
  for (final it in items) {
    final id = MarkerId(baseIdFor(it));
    map[id] = Marker(
      markerId: id,
      position: LatLng(it.latitude, it.longitude),
      infoWindow: const InfoWindow(),         // pas d'InfoWindow Google
      consumeTapEvents: true,                 // on gère nous-mêmes les taps
      icon: BitmapDescriptor.defaultMarkerWithHue(_hueFor(it)),
      onTap: () => onTap(it),
    );
  }
  return map;
}
