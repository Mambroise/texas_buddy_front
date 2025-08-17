//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/pages/map_page.dart
// Author : Morice
//---------------------------------------------------------------------------



import 'dart:async';
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
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';

// 👇 imports pour les marqueurs custom
import 'package:texas_buddy/features/map/presentation/markers/marker_bitmap_builder.dart';
import 'package:texas_buddy/features/map/presentation/markers/marker_style.dart';
import 'package:texas_buddy/features/map/presentation/markers/category_icon_mapper.dart';

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

  // --- Marqueurs custom (state persistant) ---
  late MarkerBitmapBuilder _markerBuilder;
  final Map<String, BitmapDescriptor> _iconCache = {};
  final Map<MarkerId, Marker> _markers = {};
  bool _nearbyRequestedOnce = false;

  static const LatLng _dallas = LatLng(32.7767, -96.7970);

  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(LocationStarted());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dpr = MediaQuery.of(context).devicePixelRatio;
    _markerBuilder = MarkerBitmapBuilder(pixelRatio: dpr);
  }

  void _moveCameraToLatLng(LatLng target, {double zoom = 14}) {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  void _moveCamera(UserPosition pos, {double zoom = 14}) {
    _moveCameraToLatLng(LatLng(pos.latitude, pos.longitude), zoom: zoom);
  }

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
          curr.recenterRequested,
      listener: (context, state) {
        // Centrage initial
        if (!_didInitialCenter && state.position != null) {
          final pos = state.position!;
          if (_isInTexas(pos)) {
            _moveCamera(pos);
          } else {
            _moveCameraToLatLng(_dallas, zoom: 12);
          }
          _didInitialCenter = true;

          // 👉 Nearby une seule fois, quand on a la position
          if (!_nearbyRequestedOnce) {
            _nearbyRequestedOnce = true;
            context.read<NearbyBloc>().add(
              NearbyRequested(
                latitude: pos.latitude,
                longitude: pos.longitude,
              ),
            );
          }
        }

        // Recentrage manual
        if (state.recenterRequested) {
          if (state.position != null) {
            _moveCamera(state.position!);
          } else {
            _moveCameraToLatLng(_dallas, zoom: 12);
          }
        }
      },
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final screenW = constraints.maxWidth;
            final screenH = constraints.maxHeight;

            final timelineWidth = screenW * 0.5;     // 50%
            final timelineHeight = screenH * 1.5;    // 150%
            final topOffset = screenH * 0.20;        // 70% écran
            final peekLeft = -(timelineWidth * 0.8); // 20% visible
            final fullLeft = 0.0;

            return BlocListener<NearbyBloc, NearbyState>(
              listenWhen: (prev, curr) => prev.items != curr.items,
              listener: (context, nearbyState) {
                _buildOrUpdateMarkers(nearbyState.items);
              },
              child: Stack(
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
                    markers: _markers.values.toSet(), // 👈 persistants
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
                          onToggleTap: context
                              .read<PlanningOverlayCubit>()
                              .toggleExpanded,
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
                      onPressed: () => context
                          .read<LocationBloc>()
                          .add(LocationRecenter()),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------- Helpers marqueurs ----------

  Future<BitmapDescriptor> _getIconForItem(NearbyItem it) async {
    // 1) Clé d’icône: primaryCategory (fa-xxx) en priorité
    final iconKey = (() {
      final p = (it.primaryCategory ?? '').trim();
      if (p.isNotEmpty) return p; // <- ce qu’on veut vraiment
      return it.categories.isNotEmpty ? it.categories.first : 'default'; // fallback
    })();

    // 2) Clé de cache: inclure iconKey (plus "categories.first")
    final cacheKey =
        '${it.kind}_${it.isAdvertisement}_${it.hasPromotion}_'
        '${(it.averageRating ?? -1).toStringAsFixed(1)}_${iconKey}';

    final cached = _iconCache[cacheKey];
    if (cached != null) return cached;

    // 3) Style
    MarkerStyle style = const MarkerStyle();
    if (it.kind == NearbyKind.event) style = style.forEvent();
    if (it.isAdvertisement || it.hasPromotion) style = style.promoted();
    style = style.copyWith(
      boxWidth: style.boxWidth * 0.5,
      borderWidth: 3.0,
    );

    // 4) Résolution de l’icône via le mapper (fa-xxx pris en charge)
    final iconData = CategoryIconMapper.map(iconKey);

    // 5) Dessin du bitmap (on passe aussi iconKey au cache interne du builder)
    final desc = await _markerBuilder.build(
      categoryIcon: iconData,
      averageRating: it.averageRating,
      style: style,
      categoryKey: iconKey,
    );

    _iconCache[cacheKey] = desc;
    return desc;
  }

  void _buildOrUpdateMarkers(List<NearbyItem> items) async {
    // 1) placeholders immédiats (toujours avec onTap non-null)
    final next = Map<MarkerId, Marker>.from(_markers);
    for (final it in items) {
      final id = MarkerId('${it.kind.name}_${it.id}');
      if (!next.containsKey(id)) {
        next[id] = Marker(
          markerId: id,
          position: LatLng(it.latitude, it.longitude),
          infoWindow: InfoWindow(title: it.name),
          onTap: () {}, // 👈 IMPORTANT: jamais null
        );
      }
    }
    setState(() {
      _markers
        ..clear()
        ..addAll(next);
    });

    // 2) remplacement progressif par bitmaps custom
    for (final it in items) {
      final id = MarkerId('${it.kind.name}_${it.id}');
      print("==============BEFORE _getIconForItem===================");
      print(it.primaryCategory);
      final icon = await _getIconForItem(it);
      print("==============EXIT _getIconForItem===================");
      print(icon);
      if (!mounted) return;

      final existing = _markers[id];
      if (existing == null) continue;

      // ⚠️ Recrée le Marker (plutôt que copyWith) pour être sûr de onTap/icon/anchor
      final updated = Marker(
        markerId: existing.markerId,
        position: existing.position,
        infoWindow: existing.infoWindow,
        onTap: existing.onTap ?? () {}, // 👈 toujours non-null
        icon: icon,
        anchor: const Offset(0, 1), // angle bas-gauche "pointe" visuelle
      );

      if (!mounted) return;
      setState(() => _markers[id] = updated);
    }
  }


}
