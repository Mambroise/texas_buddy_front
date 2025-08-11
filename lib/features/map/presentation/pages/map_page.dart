//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/pages/map_page.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:texas_buddy/features/map/domain/entities/user_position.dart';
import 'package:texas_buddy/features/map/presentation/blocs/location/location_bloc.dart';
import 'package:texas_buddy/features/map/presentation/blocs/location/location_event.dart';
import 'package:texas_buddy/features/map/presentation/blocs/location/location_state.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  GoogleMapController? _controller;
  bool _didInitialCenter = false;

  static const LatLng _dallas = LatLng(32.7767, -96.7970);

  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(LocationStarted());
  }

  void _moveCameraToLatLng(LatLng target, {double zoom = 14}) {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: zoom)),
    );
  }

  void _moveCamera(UserPosition pos, {double zoom = 14}) {
    _moveCameraToLatLng(LatLng(pos.latitude, pos.longitude), zoom: zoom);
  }

  bool _isInTexas(UserPosition p) {
    // BBox simple du Texas (approx.)
    // lat: ~25.5 -> 36.6 ; lon: -106.7 -> -93.5
    final lat = p.latitude;
    final lon = p.longitude;
    return lat >= 25.5 && lat <= 36.6 && lon >= -106.7 && lon <= -93.5;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<LocationBloc, LocationState>(
      listenWhen: (prev, curr) =>
      // 1) On réagit au premier point pour le centrage conditionnel
      (!_didInitialCenter && curr.position != null) ||
          // 2) Recentrage manuel via FAB
          curr.recenterRequested ||
          // (tu peux garder ou enlever cette ligne si tu ne veux pas suivre en continu)
          false,
      listener: (context, state) {
        // Centrage initial conditionnel
        if (!_didInitialCenter && state.position != null) {
          final pos = state.position!;
          if (_isInTexas(pos)) {
            _moveCamera(pos);
          } else {
            _moveCameraToLatLng(_dallas, zoom: 12);
          }
          _didInitialCenter = true;
        }

        // Recentrage manuel (on va sur l’utilisateur s’il existe, sinon Dallas)
        if (state.recenterRequested) {
          if (state.position != null) {
            _moveCamera(state.position!);
          } else {
            _moveCameraToLatLng(_dallas, zoom: 12);
          }
        }
      },
      builder: (context, state) {
        // ✅ Pas de marker custom => on laisse le vrai blue dot
        const markers = <Marker>{};

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _dallas, // point de départ si on n’a rien
                zoom: 12,
              ),
              myLocationEnabled: true,        // ✅ blue dot natif
              myLocationButtonEnabled: false, // on garde ton FAB
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              onMapCreated: (c) => _controller = c,
              markers: markers,
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'recenter',
                mini: true,
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location, color: Colors.black87),
                onPressed: () =>
                    context.read<LocationBloc>().add(LocationRecenter()),
              ),
            ),
          ],
        );
      },
    );
  }
}
