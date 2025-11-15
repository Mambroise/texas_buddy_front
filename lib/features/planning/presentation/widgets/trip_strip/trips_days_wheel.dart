//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/trip_strip/trip_days_wheel.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/features/planning/domain/entities/trip.dart';
import 'package:texas_buddy/features/planning/domain/entities/trip_day.dart';
import 'package:texas_buddy/features/map/presentation/cubits/map_focus_cubit.dart';
// + i18n sugar
import 'package:texas_buddy/core/l10n/l10n_ext.dart';

const double _kChevronWidth = 56.0; // largeur des gros chevrons

/// Affichage bandeau d’un seul TripDay à la fois, plein centre,
/// avec navigation par swipe + gros chevrons.
class TripDaysStrip extends StatefulWidget {
  final double height;
  final Trip trip;
  final VoidCallback onBack;

  /// Notifie l’extérieur lorsque le jour visible change.
  final ValueChanged<DateTime>? onCenteredDayChanged;

  /// Appelé quand l’utilisateur veut ajouter/modifier l’adresse du jour courant.
  final void Function(DateTime date, int? tripDayId)? onAddressTap;

  const TripDaysStrip({
    super.key,
    required this.height,
    required this.trip,
    required this.onBack,
    this.onCenteredDayChanged,
    this.onAddressTap,
  });

  @override
  State<TripDaysStrip> createState() => _TripDaysStripState();
}

class _TripDaysStripState extends State<TripDaysStrip> {
  late final PageController _ctl;
  late List<TripDay> _days;
  double _page = 0.0;

  int? _lastFocusedTripDayId;
  bool _didInitialFocus = false;

  int? _lastFocusedTripDayId;
  bool _didInitialFocus = false;

  @override
  void initState() {
    super.initState();
    _days = _buildDays(widget.trip);
    _ctl = PageController(viewportFraction: 1.0, initialPage: 0);
    _ctl.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureInitialFocus());
  }

  @override
  void didUpdateWidget(covariant TripDaysStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trip != widget.trip) {
      // Mémoriser la date actuellement visible pour se recaler après mise à jour.
      final int curIdx = (_ctl.page ?? 0.0).round().clamp(0, _days.length - 1);
      DateTime? curDate = _days.isNotEmpty ? _days[curIdx].date : null;

      // Régénère la liste de jours
      _days = _buildDays(widget.trip);

      // Revenir sur la même date si possible
      if (curDate != null) {
        final newIdx = _days.indexWhere((d) => _isSameYMD(d.date, curDate));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (newIdx != -1) {
            _ctl.jumpToPage(newIdx);
          } else {
            _ctl.jumpToPage(0);
          }
          setState(() {});
        });
      } else {
        setState(() {});
      }

      _didInitialFocus = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureInitialFocus());
    }
  }

  @override
  void dispose() {
    _ctl.removeListener(_onScroll);
    _ctl.dispose();
    super.dispose();
  }


  List<TripDay> _buildDays(Trip t) {
    List<TripDay> days = t.days;

    // Fallback si l’API ne renvoie pas encore 'days'
    if (days.isEmpty) {
      final start = DateTime(t.startDate.year, t.startDate.month, t.startDate.day);
      final end   = DateTime(t.endDate.year, t.endDate.month, t.endDate.day);
      final total = end.difference(start).inDays + 1;
      days = List.generate(total, (i) {
        final d = start.add(Duration(days: i));
        return TripDay(id: -1, date: d); // id inconnu côté client
      });
    }
    return days;
  }

  bool _isSameYMD(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _ensureInitialFocus() {
    if (_didInitialFocus || _days.isEmpty) return;

    final day = _days[(_ctl.page ?? 0.0).round().clamp(0, _days.length - 1)];
    final hasAddress = (day.address != null && day.address!.trim().isNotEmpty);
    final hasGeo = (day.latitude != null && day.longitude != null);

    if (hasAddress && hasGeo) {
      _lastFocusedTripDayId = day.id;
      _didInitialFocus = true;
      context.read<MapFocusCubit>().focusTripDay(day.latitude!, day.longitude!, zoom: 14);
    }
  }

  void _onScroll() {
    final p = _ctl.page ?? 0.0;
    if (p == _page) return;
    setState(() => _page = p);

    final idx = p.round().clamp(0, _days.length - 1);
    final day = _days[idx];

    widget.onCenteredDayChanged?.call(day.date);

    // 👇 protection "ne pas voler le focus d'un step créé à l'instant"
    final mapState = context.read<MapFocusCubit>().state;
    if (mapState != null &&
        mapState.source == MapFocusSource.tripStep) {
      final diff = DateTime.now().difference(mapState.at);
      if (diff.inMilliseconds < 600) {
        // si < 600ms → on laisse le step
        return;
      }
    }

    final hasAddress = (day.address != null && day.address!.trim().isNotEmpty);
    final hasGeo = (day.latitude != null && day.longitude != null);
    final notSame = (_lastFocusedTripDayId != day.id);

    if (hasAddress && hasGeo && notSame) {
      _lastFocusedTripDayId = day.id;
      context.read<MapFocusCubit>().focusTripDay(day.latitude!, day.longitude!, zoom: 14);
    }
  }


  String _fmtDate(DateTime d) =>
      MaterialLocalizations.of(context).formatShortMonthDay(d);

  // Navigation par boutons
  void _goPrev() {
    final idx = (_ctl.page ?? 0.0).round();
    if (idx > 0) {
      _ctl.animateToPage(idx - 1, duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic);
    }
  }

  void _goNext() {
    final idx = (_ctl.page ?? 0.0).round();
    if (idx < _days.length - 1) {
      _ctl.animateToPage(idx + 1, duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height;

    return SizedBox(
      height: h,
      // On garde PageView pour supporter le swipe horizontal naturellement.
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _ctl,
            itemCount: _days.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (ctx, index) {
              final day = _days[index];
              final hasAddress = (day.address != null && day.address!.trim().isNotEmpty);
              final addressText = hasAddress ? day.address! : context.l10n.tripNoAddress;

              return _DayBandContent(
                tripTitle: widget.trip.title,               // ⬅️ titre du voyage en haut
                centeredDateLabel: _fmtDate(day.date),      // ⬅️ date au centre
                address: addressText,
                hasAddress: hasAddress,
                onBack: widget.onBack,
                onAddressTap: widget.onAddressTap == null
                    ? null
                    : () => widget.onAddressTap!.call(day.date, day.id == -1 ? null : day.id),
              );
            },
          ),

          // Gros chevron gauche
          Align(
            alignment: Alignment.centerLeft,
            child: _NavChevron(
              icon: Icons.chevron_left_rounded,
              onTap: _goPrev,
            ),
          ),

          // Gros chevron droit
          Align(
            alignment: Alignment.centerRight,
            child: _NavChevron(
              icon: Icons.chevron_right_rounded,
              onTap: _goNext,
            ),
          ),
        ],
      ),
    );
  }
}

/// Contenu visuel du bandeau pour un jour.
/// - Back (haut gauche)
/// - Titre du voyage centré en haut
/// - Date en GRAND au centre (pile entre les chevrons)
/// - Icône hôtel + adresse centrés en bas
class _DayBandContent extends StatelessWidget {
  final String tripTitle;
  final String centeredDateLabel;
  final String address;
  final bool hasAddress;
  final VoidCallback onBack;
  final VoidCallback? onAddressTap;

  const _DayBandContent({
    required this.tripTitle,
    required this.centeredDateLabel,
    required this.address,
    required this.hasAddress,
    required this.onBack,
    this.onAddressTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // léger padding interne
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Back (haut gauche)
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.texasBlue,
              onPressed: onBack,
            ),
          ),

          // Titre du voyage (haut centre)
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              tripTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.texasBlue,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                height: 1.2,
              ),
            ),
          ),

          // Date en grand (centre), avec padding horizontal = largeur des chevrons
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _kChevronWidth + 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  centeredDateLabel,
                  maxLines: 1,
                  style: const TextStyle(
                    color: AppColors.texasBlue,
                    fontWeight: FontWeight.w900,
                    fontSize: 26, // "en grand"
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),

          // Hôtel + adresse (bas centre, largeur 70%)
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              widthFactor: 0.70, // ⬅️ largeur 70% du bandeau
              child: _HotelAddress(
                address: address,
                hasAddress: hasAddress,
                onTap: onAddressTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HotelAddress extends StatelessWidget {
  final String address;
  final bool hasAddress;
  final VoidCallback? onTap;

  const _HotelAddress({
    required this.address,
    required this.hasAddress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasAddress) {
      // bouton identique TimelinePane (inchangé)
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.add_location_alt, size: 12),
          label: Text(context.l10n.addHotelAddress),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.texasBlue,
            backgroundColor: AppColors.whiteGlow,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: AppColors.texasBlue, width: 1),
            ),
          ),
        ),
      );
    }

    // Adresse affichée (centrée, largeur 70% déjà imposée par le parent)
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SizedBox(
        width: double.infinity, // pour que Row ait une largeur contrainte
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.hotel_rounded, size: 20, color: AppColors.texasBlue),
            const SizedBox(width: 8),
            Expanded( // ⬅️ laisse le texte prendre la place restante
              child: Text(
                address,
                textAlign: TextAlign.center,
                softWrap: true,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _NavChevron extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavChevron({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kChevronWidth,
      height: _kChevronWidth,
      child: Material(
        type: MaterialType.transparency,
        child: InkResponse(
          onTap: onTap,
          radius: 40,
          highlightShape: BoxShape.circle,
          child: Icon(
            icon,
            size: 48,
            color: AppColors.texasBlue,
          ),
        ),
      ),
    );
  }
}
