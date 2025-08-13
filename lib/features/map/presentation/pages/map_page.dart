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
import 'package:texas_buddy/features/planning/presentation/cubit/planning_overlay_cubit.dart';
import 'package:texas_buddy/features/planning/presentation/overlay/planning_overlay.dart';
import 'package:texas_buddy/features/map/presentation/blocs/nearby/nearby_bloc.dart';



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

// check wether user is in texas when using the app. if bool = false, it disables auto recenter
  //when using app
  bool _isInTexas(UserPosition p) {
    final lat = p.latitude;
    final lon = p.longitude;
    return lat >= 25.5 && lat <= 36.6 && lon >= -106.7 && lon <= -93.5;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<LocationBloc, LocationState>(
      listenWhen: (prev, curr) =>
      (!_didInitialCenter && curr.position != null) ||
          curr.recenterRequested ||
          false,
      listener: (context, state) {
        if (!_didInitialCenter && state.position != null) {
          final pos = state.position!;
          if (_isInTexas(pos)) {
            _moveCamera(pos);
          } else {
            _moveCameraToLatLng(_dallas, zoom: 12);
          }
          _didInitialCenter = true;
        }

        // calling nearby request to get all ads and activities and events list
        final loc = state.position!;
        context.read<NearbyBloc>().add(
          NearbyRequested(latitude: state.position!.latitude, longitude: state.position!.longitude),
        );

        if (state.recenterRequested) {
          if (state.position != null) {
            _moveCamera(state.position!);
          } else {
            _moveCameraToLatLng(_dallas, zoom: 12);
          }
        }
      },
      builder: (context, state) {
        final nearbyItems = context.select((NearbyBloc b) => b.state.items);
        final markers = nearbyItems.map((it) {
          return Marker(
            markerId: MarkerId('${it.kind.name}_${it.id}'),
            position: LatLng(it.latitude, it.longitude),
            infoWindow: InfoWindow(title: it.name),
          );
        }).toSet();

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenW = constraints.maxWidth;
            final screenH = constraints.maxHeight;

            // Dimensions/calculs demandés
            final timelineWidth  = screenW * 0.5;   // 50%
            final timelineHeight = screenH * 1.5;   // 150%
            final topOffset      = screenH * 0.20;  // 70% écran
            final peekLeft       = -(timelineWidth * 0.8); // 20% visibles
            final fullLeft       = 0.0;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: _dallas,
                    zoom: 12,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  onMapCreated: (c) => _controller = c,
                  markers: markers,
                ),

                // -------------------------
                // Overlay Timeline (animé)
                // -------------------------
                BlocBuilder<PlanningOverlayCubit, PlanningOverlayState>(
                  builder: (context, ovr) {
                    if (!ovr.visible) return const SizedBox.shrink();

                    final targetLeft = ovr.expanded ? fullLeft : peekLeft;

                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOutCubic,
                      top: topOffset,
                      left: targetLeft,
                      width: timelineWidth,
                      height: timelineHeight,
                      child: PlanningOverlay(
                      width: timelineWidth,
                      height: timelineHeight,
                      onToggleTap: context.read<PlanningOverlayCubit>().toggleExpanded,
                      // Si tu veux garder ton look "bande noire / texte blanc" :
                      stripeColor: Colors.black87,
                      hourTextColor: Colors.white,
                      slotHeight: 80.0,
                    ),

                    );
                  },
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
      },
    );
  }
}
