//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/pages/map_page.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';

import 'package:texas_buddy/features/map/domain/entities/user_position.dart';
import 'package:texas_buddy/features/map/presentation/blocs/location/location_bloc.dart';
import 'package:texas_buddy/features/map/presentation/blocs/location/location_event.dart';
import 'package:texas_buddy/features/map/presentation/blocs/location/location_state.dart';

import 'package:texas_buddy/features/planning/presentation/cubit/planning_overlay_cubit.dart';
import 'package:texas_buddy/features/planning/presentation/overlay/planning_overlay.dart';

import 'package:texas_buddy/features/map/presentation/blocs/nearby/nearby_bloc.dart';
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';
import 'package:texas_buddy/features/map/presentation/markers/category_icon_mapper.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool _labelAnimBusy = false;

  GoogleMapController? _controller;
  bool _didInitialCenter = false;

  // Debounce pour onCameraIdle
  Timer? _idleDebounce;

  // --- Marqueurs custom (state persistant) ---
  final Map<MarkerId, Marker> _markers = {};

  static const LatLng _dallas = LatLng(32.7767, -96.7970);

  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(LocationStarted());
  }

  @override
  void dispose() {
    _idleDebounce?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  // requête en fonction du zoom et des bounds
  void _onCameraIdle() async {
    if (_controller == null) return;

    _idleDebounce?.cancel();
    _idleDebounce = Timer(const Duration(milliseconds: 300), () async {
      final b = await _controller!.getVisibleRegion();
      final z = await _controller!.getZoomLevel();

      // TODO: remplace par ton cubit de filtres quand prêt
      const filters = <String>[];

      // ✅ recale les badges actuels à la nouvelle vue (sans re-fetch)
      if (_lastItems.isNotEmpty) {
        for (final it in _lastItems) {
          final idBase = MarkerId(_baseIdFor(it));
          if (_markers.containsKey(idBase)) {
            _updateOneLabel(it);
          }
        }
      }

      // ✅ déclenche la requête bounds-aware
      context.read<NearbyBloc>().add(
        NearbyRequestedBounds(
          north: b.northeast.latitude,
          east:  b.northeast.longitude,
          south: b.southwest.latitude,
          west:  b.southwest.longitude,
          zoom: z.round(),
          limit: 0,              // 0 => le bloc calcule via _capForZoom
          categoryKeys: filters, // category=fa-... (répétés)
        ),
      );
    });
  }


  bool _isInTexas(UserPosition p) {
    final lat = p.latitude;
    final lon = p.longitude;
    return lat >= 25.5 && lat <= 36.6 && lon >= -106.7 && lon <= -93.5;
  }

  //MARKER CUSTOM PART
// ----------------------------------------------
// Badges au-dessus des pins
  final Map<String, BitmapDescriptor> _labelCache = {};
  final Map<String, double> _labelWidthCache = {};   // ← pour calculer l’ancre X
  final Set<String> _expandedLabelIds = {};          // ids des badges élargis
  List<NearbyItem> _lastItems = [];                  // dernière liste pour recaler

  String _baseIdFor(NearbyItem it)  => '${it.kind.name}_${it.id}';
  String _labelIdFor(NearbyItem it) => 'label_${it.kind.name}_${it.id}';

  Future<LatLng> _latLngAbove(LatLng base, {int dyPx = 26}) async {
    if (_controller == null) return base;
    final sc = await _controller!.getScreenCoordinate(base);
    final above = ScreenCoordinate(x: sc.x, y: math.max(0, sc.y - dyPx));
    return _controller!.getLatLng(above);
  }

  String _labelCacheKey(NearbyItem it, bool expanded) {
    final themeMode = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final keyPart = it.primaryCategory ?? 'default';
    return 'lbl_${keyPart}_${expanded ? "x" : "_"}_${themeMode.name}';
  }

  Future<BitmapDescriptor> _buildLabelBadge(
      NearbyItem it, {
        required bool expanded,
        double opacity = 1.0, // 0..1 pour l’animation
      }) async {
    final keyPart  = it.primaryCategory ?? 'default';
    final cacheKey = 'lbl_${keyPart}_${expanded ? "x" : "_"}';

// On ne met **en cache** que l’état final (opacity == 1).
    if (opacity == 1.0) {
      final cached = _labelCache[cacheKey];
      if (cached != null) return cached;
    }

    final dpr = MediaQuery.of(context).devicePixelRatio;

// Dimensions logiques
    const double h        = 26;
    const double padH     = 8;
    const double gap      = 6;
    const double iconSize = 25;

    final IconData icon = CategoryIconMapper.map(it.primaryCategory ?? '');
    final String name   = it.name;

// Style texte avec opacité
// Style du texte (anime l’alpha)
    final ui.TextStyle textStyle = ui.TextStyle(
      color: const Color(0xFF000000).withValues( alpha: opacity),
      fontSize: 16,
      fontWeight: ui.FontWeight.w600,
    );
// Mesure du texte (si expanded)
    final pb = ui.ParagraphBuilder(
      ui.ParagraphStyle(textDirection: TextDirection.ltr),
    )..pushStyle(textStyle)
      ..addText(expanded ? ' $name' : '');
    final paragraph = pb.build();
    paragraph.layout(const ui.ParagraphConstraints(width: 1000));

    final double textWidth = expanded ? paragraph.maxIntrinsicWidth : 0.0;
    final double width = (padH * 2) + iconSize + (expanded ? gap + textWidth : 0);

// Canvas transparent
    final recorder = ui.PictureRecorder();
    final canvas   = Canvas(recorder);


// Background (anime l’alpha)
    if (expanded) {
      final bgPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.92 * opacity);
      final rrect = RRect.fromLTRBR(0, 0, width, h, const Radius.circular(14));
      canvas.drawRRect(rrect, bgPaint);
    }

// Icône (NE PAS animer l’alpha → reste 100% visible)
    final iconTp = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: iconSize,
          color: Colors.black87, // 👈 plus de .withOpacity(opacity)
        ),
      ),
    )..layout();
    iconTp.paint(canvas, Offset(padH, (h - iconTp.height) / 2));

// Texte (à droite, si expanded)
    if (expanded) {
      final textX = padH + iconSize + gap;
      final textY = (h - paragraph.height) / 2;
      canvas.drawParagraph(paragraph, Offset(textX, textY));
    }

// Export → PNG @ DPR
    final picture = recorder.endRecording();
    final img = await picture.toImage((width * dpr).ceil(), (h * dpr).ceil());
    final bytes = (await img.toByteData(format: ui.ImageByteFormat.png))!
        .buffer.asUint8List();

    final desc = BitmapDescriptor.bytes(bytes);

// Cache uniquement l’état final
    if (opacity == 1.0) {
      _labelCache[cacheKey] = desc;
      _labelWidthCache[cacheKey] = width;
    }
    return desc;

  }

  Future<void> _updateOneLabel(NearbyItem it, {double opacity = 1.0}) async {
    // état courant (compact / étendu)
    final bool isExpanded = _expandedLabelIds.contains(_baseIdFor(it));
    final String keyPart  = it.primaryCategory ?? 'default';
    final String cacheKey = 'lbl_${keyPart}_${isExpanded ? "x" : "_"}';

    // position du badge (au‑dessus du pin)
    final LatLng base  = LatLng(it.latitude, it.longitude);
    final LatLng label = await _latLngAbove(base, dyPx: 26);

    // bitmap avec opacité animée
    final BitmapDescriptor bmp =
    await _buildLabelBadge(it, expanded: isExpanded, opacity: opacity);

    // largeur pour l’ancre (utilise le cache si dispo, sinon estimation)
    final double width = _labelWidthCache[cacheKey] ?? (() {
      const double padH     = 8;
      const double gap      = 6;
      const double iconSize = 25;
      if (!isExpanded) return (padH * 2) + iconSize;
      final ui.Paragraph tmp = (() {
        final pb = ui.ParagraphBuilder(
          ui.ParagraphStyle(textDirection: TextDirection.ltr), // sans const
        )
          ..pushStyle(ui.TextStyle(fontSize: 16, fontWeight: ui.FontWeight.w600))
          ..addText(' ${it.name}');
        final p = pb.build();
        p.layout(const ui.ParagraphConstraints(width: 1000));
        return p;
      })();
      final tw = tmp.maxIntrinsicWidth;
      return (padH * 2) + iconSize + gap + tw;
    })();

    // ancre centrée sur l’icône, décalée de +12 px vers la droite
    const double padH     = 8;
    const double iconSize = 25;
    final double anchorX  = (padH + iconSize / 2 - 12) / width;
    const double anchorY  = 1.0;

    // (re)création du marker-badge
    final id = MarkerId(_labelIdFor(it));
    final m = Marker(
      markerId: id,
      position: label,
      icon: bmp,
      anchor: Offset(anchorX, anchorY),
      consumeTapEvents: true,
      onTap: () async {
        await _toggleExpand(it);
        if (mounted) setState(() {});
      },
    );

    if (!mounted) return;
    setState(() {
      _markers[id] = m;
    });
  }



  Future<void> _toggleExpand(NearbyItem it) async {
    if (_labelAnimBusy) return;
    _labelAnimBusy = true;

    final String key = _baseIdFor(it);
    final bool isCurrentlyExpanded = _expandedLabelIds.contains(key);

    // --- EXPAND ---
    if (!isCurrentlyExpanded) {
      // 1) replie tout ce qui est ouvert
      if (_expandedLabelIds.isNotEmpty) {
        final prevKeys = List<String>.from(_expandedLabelIds);
        _expandedLabelIds.clear(); // ils deviennent compacts
        // re-render immédiat des précédents en compact
        for (final k in prevKeys) {
          for (final item in _lastItems) {
            if (_baseIdFor(item) == k) {
              await _updateOneLabel(item, opacity: 1.0);
              break;
            }
          }
        }
      }

      // 2) ouvre le nouveau (anim: fond + texte seulement)
      _expandedLabelIds.add(key);
      const int steps = 8;
      for (int i = 1; i <= steps; i++) {
        final t = i / steps; // 0.125 .. 1.0
        await _updateOneLabel(it, opacity: t);
        if (mounted) setState(() {});
        await Future.delayed(const Duration(milliseconds: 24));
      }
      await _updateOneLabel(it, opacity: 1.0);
      if (mounted) setState(() {});

      _labelAnimBusy = false;
      return;
    }

    // --- COLLAPSE (du même pin) ---
    const int steps = 8;
    for (int i = steps - 1; i >= 0; i--) {
      final t = i / steps; // 0.875 .. 0.0
      await _updateOneLabel(it, opacity: t);
      if (mounted) setState(() {});
      await Future.delayed(const Duration(milliseconds: 24));
    }
    _expandedLabelIds.remove(key);
    await _updateOneLabel(it, opacity: 1.0); // compact
    if (mounted) setState(() {});

    _labelAnimBusy = false;
  }




  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<LocationBloc, LocationState>(
      listenWhen: (prev, curr) =>
      (!_didInitialCenter && curr.position != null) || curr.recenterRequested,
      listener: (context, state) {
        // Centrage initial (on ne déclenche plus de Nearby ici)
        if (!_didInitialCenter && state.position != null) {
          final pos = state.position!;
          if (_isInTexas(pos)) {
            _moveCamera(pos);
          } else {
            _moveCameraToLatLng(_dallas, zoom: 12);
          }
          _didInitialCenter = true;
        }

        // Recentrage manuel
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
            final topOffset = screenH * 0.20;        // 20% depuis le haut
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
                    onMapCreated: (c) {
                      _controller = c;
                      // 1er fetch bounds-aware après la 1re frame
                      WidgetsBinding.instance.addPostFrameCallback((_) => _onCameraIdle());
                    },
                    // cancel le debounce tant que ça bouge
                    onCameraMove: (_) => _idleDebounce?.cancel(),
                    onCameraIdle: _onCameraIdle,

                    markers: _markers.values.toSet(),
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
                      onPressed: () =>
                          context.read<LocationBloc>().add(LocationRecenter()),
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



  void _buildOrUpdateMarkers(List<NearbyItem> items) async {
    _lastItems = items; // pour recaler au prochain onCameraIdle

    // 1) Pins natifs
    final next = <MarkerId, Marker>{};
    for (final it in items) {
      final id = MarkerId(_baseIdFor(it));
      next[id] = Marker(
        markerId: id,
        position: LatLng(it.latitude, it.longitude),
        // Plus d'InfoWindow Google :
        infoWindow: const InfoWindow(), // vide => rien ne s’affiche
        consumeTapEvents: true,         // on gère le tap nous-mêmes
        icon: BitmapDescriptor.defaultMarkerWithHue(225.0),
        onTap: () async {
          await _toggleExpand(it); // unifie le comportement
          if (mounted) setState(() {});
        },
      );
    }
    if (!mounted) return;
    setState(() {
      _markers
        ..clear()
        ..addAll(next);
    });

    // 2) Badges par-dessus (asynchrone)
    for (final it in items) {
      await _updateOneLabel(it);
    }
  }




}
