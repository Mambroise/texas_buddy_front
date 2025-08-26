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
import 'package:texas_buddy/features/map/presentation/cubits/category_filter_cubit.dart';
import 'package:texas_buddy/features/map/presentation/widgets/category_chip_bar.dart';

// ⬇️ Layers (pins + labels)
import 'package:texas_buddy/features/map/presentation/layers/pins_layer.dart';
import 'package:texas_buddy/features/map/presentation/layers/labels_layer.dart';

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

  // Debounce for onCameraIdle
  Timer? _idleDebounce;

  // Live markers rendered on the map (pins + labels)
  final Map<MarkerId, Marker> _markers = {};

  // Label layer (render/anim/toggle/recalc)
  late final LabelsLayer _labels;

  // Last server items (used for recalc + local filter)
  List<NearbyItem> _lastItems = [];

  static const LatLng _dallas = LatLng(32.7767, -96.7970);

  @override
  void initState() {
    super.initState();
    _labels = LabelsLayer(context);
    context.read<LocationBloc>().add(LocationStarted());
  }

  @override
  void dispose() {
    _idleDebounce?.cancel();
    super.dispose();
  }

  List<String> _categoryKeysOnly() {
    final sel = context.read<CategoryFilterCubit>().state;
    return sel.where((k) => !k.startsWith('__TYPE:')).toList();
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

  // Fetch on camera idle + recalc label positions
  void _onCameraIdle() async {
    if (_controller == null) return;

    _idleDebounce?.cancel();
    _idleDebounce = Timer(const Duration(milliseconds: 300), () async {
      final b = await _controller!.getVisibleRegion();
      final z = await _controller!.getZoomLevel();
      final cats = _categoryKeysOnly();

      // Recalculate label positions to stay above pins
      if (_lastItems.isNotEmpty) {
        await _labels.recalcPositions(
          items: _lastItems,
          controller: _controller!,
          onBulk: _applyLabelFull,   // recalc complet
          onPatch: _applyLabelPatch, // tap label = patch
        );
      }

      // Bounds-aware request with current filters
      context.read<NearbyBloc>().add(
        NearbyRequestedBounds(
          north: b.northeast.latitude,
          east:  b.northeast.longitude,
          south: b.southwest.latitude,
          west:  b.southwest.longitude,
          zoom: z.round(),
          limit: 0,
          categoryKeys: cats,
        ),
      );
    });
  }

  bool _isInTexas(UserPosition p) {
    final lat = p.latitude;
    final lon = p.longitude;
    return lat >= 25.5 && lat <= 36.6 && lon >= -106.7 && lon <= -93.5;
  }

  // Instant local render with current filters (no server call)
  void _applyFiltersAndRender() {
    final selected = context.read<CategoryFilterCubit>().state;
    final eventsOnly = selected.contains(CategoryFilterCubit.typeEventToken);

    List<NearbyItem> filtered;
    if (eventsOnly) {
      // garde uniquement les "event"
      filtered = _lastItems.where((it) => it.kind == NearbyKind.event).toList();
    } else if (selected.isEmpty) {
      filtered = _lastItems;
    } else {
      // filtre par catégories (primaryCategory) comme avant
      filtered = _lastItems.where(
              (it) => it.primaryCategory != null && selected.contains(it.primaryCategory!)
      ).toList();
    }

    _buildOrUpdateMarkers(filtered);
  }


  // Server refetch with current bounds + filters
  void _fetchWithCurrentBounds() async {
    if (_controller == null) return;
    final b = await _controller!.getVisibleRegion();
    final z = await _controller!.getZoomLevel();
    final cats = _categoryKeysOnly();

    context.read<NearbyBloc>().add(
      NearbyRequestedBounds(
        north: b.northeast.latitude,
        east:  b.northeast.longitude,
        south: b.southwest.latitude,
        west:  b.southwest.longitude,
        zoom: z.round(),
        limit: 0,
        categoryKeys: cats,
      ),
    );
  }

// PATCH: merge only the changed labels (do NOT clear others)
  void _applyLabelPatch(Map<MarkerId, Marker> patch) {
    if (!mounted) return;
    setState(() {
      _markers.addAll(patch); // same ids get overwritten
    });
  }

// FULL: replace all label_* markers at once
  void _applyLabelFull(Map<MarkerId, Marker> full) {
    if (!mounted) return;
    setState(() {
      _markers.removeWhere((id, _) => id.value.startsWith('label_'));
      _markers.addAll(full);
    });
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<LocationBloc, LocationState>(
      listenWhen: (prev, curr) =>
      (!_didInitialCenter && curr.position != null) || curr.recenterRequested,
      listener: (context, state) {
        // Initial center (no Nearby fetch here)
        if (!_didInitialCenter && state.position != null) {
          final pos = state.position!;
          if (_isInTexas(pos)) {
            _moveCamera(pos);
          } else {
            _moveCameraToLatLng(_dallas, zoom: 12);
          }
          _didInitialCenter = true;
        }

        // Manual recenter
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
            final topOffset = screenH * 0.20;        // 20% from top
            final peekLeft = -(timelineWidth * 0.8); // 20% visible
            final fullLeft = 0.0;

            return BlocListener<NearbyBloc, NearbyState>(
              listenWhen: (prev, curr) => prev.items != curr.items,
              listener: (context, nearbyState) {
                _lastItems = nearbyState.items; // garde la dernière réponse brute
                _applyFiltersAndRender();       // puis applique les filtres courants (events/cats)
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Google Map
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: _dallas,
                      zoom: 12,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapType: MapType.normal,
                    onMapCreated: (c) {
                      _controller = c;
                      // first bounds-aware fetch after first frame
                      WidgetsBinding.instance.addPostFrameCallback((_) => _onCameraIdle());
                    },
                    onCameraMove: (_) => _idleDebounce?.cancel(),
                    onCameraIdle: _onCameraIdle,
                    markers: _markers.values.toSet(),
                  ),

                  // Category chip bar
                  Positioned(
                    top: 8, left: 8, right: 8,
                    child: CategoryChipsBar(
                      onChanged: () {
                        _applyFiltersAndRender();  // local, instant
                        _fetchWithCurrentBounds(); // server, bounds+filters
                      },
                    ),
                  ),

                  // Planning overlay
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
                          stripeColor: Colors.black87,
                          hourTextColor: Colors.white,
                          slotHeight: 80.0,
                        ),
                      );
                    },
                  ),

                  // Recenter FAB
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      heroTag: 'recenter',
                      mini: true,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.my_location, color: Colors.black87),
                      onPressed: () => context.read<LocationBloc>().add(LocationRecenter()),
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

  // ---------- Markers orchestration (pins + labels via layers) ----------

  void _buildOrUpdateMarkers(List<NearbyItem> items) async {
    _lastItems = items;

    // 1) Base Google pins via external layer
    final nextPins = buildGooglePins(
      items: items,
      onTap: (it) async {
        if (_controller == null) return;
        // open/close the label above this pin
        await _labels.toggleExpand(
          it,
          items: _lastItems,
          controller: _controller!,
          onPatch: _applyLabelPatch, // ← surtout pas full ici
        );
      },
    );

    if (!mounted) return;
// pins…
    setState(() {
      _markers
        ..clear()
        ..addAll(nextPins);
    });

    // 2) Labels above pins (async build via labels layer)
    if (_controller != null) {
      await _labels.updateForItems(
        items: items,
        controller: _controller!,
        onBulk: _applyLabelFull,
        onPatch: _applyLabelPatch,
      );
    }
  }
}
