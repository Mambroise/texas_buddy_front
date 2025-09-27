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

import 'package:texas_buddy/core/theme/app_colors.dart';

import 'package:texas_buddy/features/map/domain/entities/user_position.dart';
import 'package:texas_buddy/features/map/presentation/blocs/location/location_bloc.dart';
import 'package:texas_buddy/features/map/presentation/blocs/location/location_event.dart';
import 'package:texas_buddy/features/map/presentation/blocs/location/location_state.dart';
import 'package:texas_buddy/features/map/presentation/cubits/map_focus_cubit.dart';

import 'package:texas_buddy/features/planning/presentation/widgets/planning_overlay_dock.dart';

//detail activity and event
import 'package:texas_buddy/features/map/presentation/blocs/detail/detail_panel_bloc.dart';
import 'package:texas_buddy/features/map/presentation/widgets/detail_panel.dart';

import 'package:texas_buddy/features/map/presentation/blocs/nearby/nearby_bloc.dart';
import 'package:texas_buddy/features/map/presentation/blocs/all_events/all_events_bloc.dart';
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';
import 'package:texas_buddy/features/map/presentation/cubits/category_filter_cubit.dart';
import 'package:texas_buddy/features/map/presentation/cubits/map_mode_cubit.dart';
import 'package:texas_buddy/features/map/presentation/widgets/category_chip_bar.dart';
import 'package:texas_buddy/features/map/presentation/layers/planning_scrim_layer.dart';

// Layers (pins + labels)
import 'package:texas_buddy/features/map/presentation/layers/pins_layer.dart';
import 'package:texas_buddy/features/map/presentation/layers/labels_layer.dart';

// L10n
import 'package:texas_buddy/core/l10n/l10n_ext.dart';

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


  // DETAIL FOR ACTIVITY AND EVENT PART
  String? _lastTappedMarkerId;
  DateTime? _lastTapTime;
  final _doubleTapWindow = const Duration(milliseconds: 280);



  static const LatLng _dallas = LatLng(32.7767, -96.7970);

  @override
  void initState() {
    super.initState();
    _labels = LabelsLayer(
      context,
      onLabelTap: (NearbyItem it) {
        _onLabelTap(
          id: it.id,
          isEvent: it.kind == NearbyKind.event,
          //placeId: it.id, pas utilisé pour l'instant
        );
      },
    );
    context.read<LocationBloc>().add(LocationStarted());
  }


  @override
  void dispose() {
    _idleDebounce?.cancel();
    super.dispose();
  }

  // --- Helpers -------------------------------------------------------------


  //---------------DETAIL ACTIVITY AND EVENT--------------------

  NearbyItem? _findItemById(String id) {
    for (final it in _lastItems) {
      if ('${it.kind.name}_${it.id}' == id || it.id == id) return it;
    }
    return null;
  }

  /// Ouvre/actualise le label au-dessus du pin.
  Future<void> _showMarkerLabel(String id) async {
    if (_controller == null) return;
    final it = _findItemById(id);
    if (it == null) return;

    await _labels.toggleExpand(
      it,
      items: _lastItems,
      controller: _controller!,
      onPatch: _applyLabelPatch,
    );
  }

  void _onMarkerTap(String id, {required bool isEvent, String? placeId}) {
    final now = DateTime.now();
    final isSame = _lastTappedMarkerId == id && _lastTapTime != null && now.difference(_lastTapTime!) <= _doubleTapWindow;
    _lastTappedMarkerId = id;
    _lastTapTime = now;


    if (isSame) {
// DOUBLE TAP → open detail panel
      final bloc = context.read<DetailPanelBloc>();
      bloc.add(DetailOpenRequested(
        type: isEvent ? DetailType.event : DetailType.activity,
        idOrPlaceId: placeId ?? id,
        byPlaceId: placeId != null,
      ));
    } else {
// SINGLE TAP → your existing logic to show the name label
      _showMarkerLabel(id);
    }
  }

  void _onLabelTap({required String id, required bool isEvent, String? placeId}) {
    context.read<DetailPanelBloc>().add(DetailOpenRequested(
      type: isEvent ? DetailType.event : DetailType.activity,
      idOrPlaceId: placeId ?? id,
      byPlaceId: placeId != null,
    ));
  }
//-----------------------------------------------------------------------

  MapListingMode _mode() => context.read<MapModeCubit>().state.mode;

// On ne retourne que les clés d'icônes de catégorie (pas les tokens spéciaux).
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

  bool _isInTexas(UserPosition p) {
    final lat = p.latitude;
    final lon = p.longitude;
    return lat >= 25.5 && lat <= 36.6 && lon >= -106.7 && lon <= -93.5;
  }

  void _animateTo(double lat, double lng, double zoom) {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(lat, lng),
        zoom: zoom,
      )),
    );
  }

  // --- Fetch orchestration -------------------------------------------------

  // Fetch on camera idle + recalc label positions
  void _onCameraIdle() async {
    if (_controller == null) return;

    _idleDebounce?.cancel();
    _idleDebounce = Timer(const Duration(milliseconds: 300), () async {
      final b = await _controller!.getVisibleRegion();
      final z = await _controller!.getZoomLevel();

      // Recalculate label positions to stay above pins
      if (_lastItems.isNotEmpty) {
        await _labels.recalcPositions(
          items: _lastItems,
          controller: _controller!,
          onBulk: _applyLabelFull,   // full recalc
          onPatch: _applyLabelPatch, // tap label = patch
        );
      }

      // Bounds-aware request with current filters (by mode)
      final cats = _categoryKeysOnly();
      if (_mode() == MapListingMode.events) {
        context.read<AllEventsBloc>().add(AllEventsLoadInBounds(
          north: b.northeast.latitude,
          east:  b.northeast.longitude,
          south: b.southwest.latitude,
          west:  b.southwest.longitude,
          zoom: z.round(),
          year: DateTime.now().year,
          useCache: true,
        ));
      } else {
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
    });
  }

  /// Match si la catégorie principale OU l'une des catégories secondaires est sélectionnée.
  bool _itemMatchesCategories(NearbyItem it, Set<String> selectedCats) {
    if (selectedCats.isEmpty) return true;

    final pc = it.primaryCategory;
    if (pc != null && selectedCats.contains(pc)) return true;

    for (final c in it.categories) {
      if (selectedCats.contains(c)) return true;
    }
    return false;
  }


  // Instant local render with current filters (no server call)
  void _applyFiltersAndRender() {
    final selected = context.read<CategoryFilterCubit>().state;

    List<NearbyItem> filtered;
    if (_mode() == MapListingMode.events) {
      // En mode Events, _lastItems ne contient QUE des events.
      if (selected.isEmpty) {
        filtered = _lastItems;
      } else {
        final cats = _categoryKeysOnly();
        if (cats.isEmpty) {
          filtered = _lastItems;
        } else {
          final sel = Set<String>.from(cats);
          filtered = _lastItems.where((it) => _itemMatchesCategories(it, sel)).toList();
        }
      }
    } else {
      // Mode Nearby (mix activités + events)
      final eventsOnly = selected.contains(CategoryFilterCubit.typeEventToken);
      if (eventsOnly) {
        // On conserve le comportement existant : "Events" est un mode exclusif.
        filtered = _lastItems.where((it) => it.kind == NearbyKind.event).toList();
      } else if (selected.isEmpty) {
        filtered = _lastItems;
      } else {
        final cats = _categoryKeysOnly();
        if (cats.isEmpty) {
          filtered = _lastItems;
        } else {
          final sel = Set<String>.from(cats);
          filtered = _lastItems.where((it) => _itemMatchesCategories(it, sel)).toList();
        }
      }
    }

    _buildOrUpdateMarkers(filtered);
  }


  // Server refetch with current bounds + filters (by mode)
  Future<void> _fetchWithCurrentBounds() async {
    if (_controller == null) return;
    final b = await _controller!.getVisibleRegion();
    final z = await _controller!.getZoomLevel();

    if (_mode() == MapListingMode.events) {
      context.read<AllEventsBloc>().add(AllEventsLoadInBounds(
        north: b.northeast.latitude,
        east:  b.northeast.longitude,
        south: b.southwest.latitude,
        west:  b.southwest.longitude,
        zoom: z.round(),
        year: DateTime.now().year,
        useCache: true,
      ));
    } else {
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
  }

  // ---------- Markers orchestration (pins + labels via layers) -------------

  void _applyLabelPatch(Map<MarkerId, Marker> patch) {
    if (!mounted) return;
    setState(() {
      _markers.addAll(patch); // same ids get overwritten
    });
  }

  void _applyLabelFull(Map<MarkerId, Marker> full) {
    if (!mounted) return;
    setState(() {
      _markers.removeWhere((id, _) => id.value.startsWith('label_'));
      _markers.addAll(full);
    });
  }

  void _buildOrUpdateMarkers(List<NearbyItem> items) async {
    _lastItems = items;

    // 1) Base Google pins via external layer
    final nextPins = buildGooglePins(
      items: items,
      onTap: (it) async {
        _onMarkerTap(
          it.id,
          isEvent: it.kind == NearbyKind.event,
          //placeId: it.placeId, not used by now
        );
      },
    );

    if (!mounted) return;

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

  // --- Build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = context.l10n;

    return MultiBlocListener(
      listeners: [
        // 1) When mode changes, clear and refetch with current bounds
        BlocListener<MapModeCubit, MapModeState>(
          listenWhen: (prev, curr) => prev.mode != curr.mode,
          listener: (ctx, state) async {
            // 1) Clear current view
            setState(() {
              _markers.clear();
              _lastItems = [];
            });

            // 2) Cancel any pending debounce from previous mode
            _idleDebounce?.cancel();

            // 3) Let the frame apply before refetching
            await Future<void>.delayed(const Duration(milliseconds: 1));
            if (!mounted) return;

            // 4) Refetch according to current bounds and mode
            await _fetchWithCurrentBounds();
          },
        ),

        // 2) Nearby → only render if we are in Nearby mode
        BlocListener<NearbyBloc, NearbyState>(
          listener: (ctx, st) {
            if (_mode() != MapListingMode.nearby) return;
            _lastItems = st.items;
            _applyFiltersAndRender();
          },
        ),

        // 3) AllEvents → only render if we are in Events mode
        BlocListener<AllEventsBloc, AllEventsState>(
          listener: (ctx, st) {
            if (_mode() != MapListingMode.events) return;
            if (st.status == AllEventsStatus.ready) {
              _lastItems = st.items;
              _applyFiltersAndRender();
            }
          },
        ),

        // 4) Initial location / recenter
        BlocListener<LocationBloc, LocationState>(
          listenWhen: (prev, curr) =>
          (!_didInitialCenter && curr.position != null) || curr.recenterRequested,
          listener: (context, state) {
            // Initial center (no fetch here)
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
        ),

        BlocListener<MapFocusCubit, MapFocusState?>(
          listener: (ctx, st) {
            if (st == null) return;
            _animateTo(st.latitude, st.longitude, st.zoom);
          },
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
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
                  // ✅ rejoue le dernier focus en attente (si émis avant la création du controller)
                  final pending = context.read<MapFocusCubit>().state;
                  if (pending != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _controller?.animateCamera(CameraUpdate.newCameraPosition(
                        CameraPosition(target: LatLng(pending.latitude, pending.longitude), zoom: pending.zoom),
                      ));
                    });
                  }
                  // first bounds-aware fetch after first frame
                  WidgetsBinding.instance.addPostFrameCallback((_) => _onCameraIdle());
                },
                onCameraMove: (_) => _idleDebounce?.cancel(),
                onCameraIdle: _onCameraIdle,
                markers: _markers.values.toSet(),
              ),

              // Recenter FAB
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  heroTag: 'recenter',
                  mini: true,
                  backgroundColor: Colors.white,
                  tooltip: l10n.recenterMap,
                  child: const Icon(Icons.my_location, color: Colors.black87),
                  onPressed: () => context.read<LocationBloc>().add(LocationRecenter()),
                ),
              ),

              // ⬇️ SCRIM VISUEL (dimming.ne bloque pas la carte) voile sur carte
              const PlanningScrimLayer(
                expandedOpacity: 0.78,   // ex: plus sombre en expanded
                collapsedOpacity: 0.22,  // ex: plus sombre en collapsed
                // absorbGestures: true,  // si un jour tu veux bloquer la map sous le voile
              ),

              // Category chip bar
              Positioned(
                top: 8, left: 8, right: 8,
                child: CategoryChipsBar(
                  onChanged: () {
                    _applyFiltersAndRender();  // local, instant
                    _fetchWithCurrentBounds(); // server, bounds+mode
                  },
                ),
              ),
              DetailPanel(onClose: () => context.read<DetailPanelBloc>().add(const DetailCloseRequested())),

              // Planning overlay
              const PlanningOverlayDock(
                stripeColor: AppColors.fog,         // try AppColors.linen, .almond, .desertSand
                hourTextColor: AppColors.texasBlue,
              ),
            ],
          );
        },
      ),
    );
  }
}
