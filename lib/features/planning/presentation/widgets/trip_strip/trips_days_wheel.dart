// features/planning/presentation/widgets/trip_strip/trip_days_wheel.dart
import 'package:flutter/material.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/features/planning/domain/entities/trip.dart';
import 'package:texas_buddy/features/planning/domain/entities/trip_day.dart';
// + i18n sugar
import 'package:texas_buddy/core/l10n/l10n_ext.dart';


class TripDaysStrip extends StatefulWidget {
  final double height;
  final Trip trip;
  final VoidCallback onBack;
  final ValueChanged<DateTime>? onCenteredDayChanged;
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
  late final List<_Item> _items; // [arrival] + days + [departure]
  double _page = 1.0;

  @override
  void initState() {
    super.initState();
    _items = _buildItems(widget.trip);
    _ctl = PageController(viewportFraction: 0.26, initialPage: 1);
    _ctl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _ctl.removeListener(_onScroll);
    _ctl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final p = _ctl.page ?? 0.0;
    if (p == _page) return;
    setState(() => _page = p);

    final idx = p.round().clamp(0, _items.length - 1);
    final it = _items[idx];
    if (it.type == _ItemType.day && widget.onCenteredDayChanged != null) {
      widget.onCenteredDayChanged!(it.day!.date);
    }
  }

  List<_Item> _buildItems(Trip t) {
    List<TripDay> days = t.days;

    // fallback si l’API ne renvoie pas encore 'days'
    if (days.isEmpty) {
      final start = DateTime(t.startDate.year, t.startDate.month, t.startDate.day);
      final end   = DateTime(t.endDate.year, t.endDate.month, t.endDate.day);
      final total = end.difference(start).inDays + 1;
      days = List.generate(total, (i) {
        final d = start.add(Duration(days: i));
        return TripDay(id: -1, date: d); // id inconnu côté client
      });
    }

    return [
      const _Item.arrival(),
      ...days.map(_Item.dayFrom),
      const _Item.departure(),
    ];
  }

  double _scaleFor(int index) {
    final dist = (index - _page).abs();
    final isMarker = _items[index].type != _ItemType.day;
    if (isMarker) {
      if (dist < 0.5) return 1.0;
      if (dist < 1.5) return 1.0;
      return 1.0;
    } else {
      if (dist < 0.5) return 1.6;   // centre
      if (dist < 1.5) return 0.8;   // voisins
      return 0.6;                   // autres
    }
  }

  String _fmt(DateTime d) => MaterialLocalizations.of(context).formatShortMonthDay(d);

  @override
  Widget build(BuildContext context) {
    final h = widget.height;

    return SizedBox(
      height: h,
      child: Column(
        children: [
          // header
          Padding(
            padding: const EdgeInsets.symmetric( vertical: 6),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.fog,
                  onPressed: widget.onBack,
                ),
                const SizedBox(width: 1),
                Expanded(
                  child: Text(
                    widget.trip.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.fog,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // liste horizontale avec effet scale (date TOUJOURS visible)
          Expanded(
            child: PageView.builder(
              controller: _ctl,
              itemCount: _items.length,
              physics: const BouncingScrollPhysics(),
              padEnds: true,
              itemBuilder: (ctx, index) {
                final it = _items[index];
                final scale = _scaleFor(index);

                return GestureDetector(
                  onTap: () => _ctl.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                  ),
                  child: Align(
                    child: switch (it.type) {
                      _ItemType.arrival   => _MarkerIcon(icon: Icons.flight_land, scale: scale),
                      _ItemType.departure => _MarkerIcon(icon: Icons.flight_takeoff, scale: scale),
                      _ItemType.day => _DayColumnItem(
                        dateLabel: _fmt(it.day!.date),
                        address: it.day!.address,
                        scale: scale, // <— au lieu de scaleBody
                        onAddAddress: widget.onAddressTap == null
                            ? null
                            : () => widget.onAddressTap!(it.day!.date, it.day!.id == -1 ? null : it.day!.id),
                      ),
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- types internes UI -----------------------------------------------------

enum _ItemType { arrival, day, departure }

class _Item {
  final _ItemType type;
  final TripDay? day;

  const _Item._(this.type, this.day);

  const _Item.arrival()   : this._(_ItemType.arrival, null);
  const _Item.departure() : this._(_ItemType.departure, null);
  const _Item.day(TripDay d) : this._(_ItemType.day, d);

  static _Item dayFrom(TripDay d) => _Item.day(d);
}

// ── Icône “marqueur”, on applique le scale ici aussi ───────────────────────
class _MarkerIcon extends StatelessWidget {
  const _MarkerIcon({required this.icon, required this.scale});
  final IconData icon;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 150,
      child: Center(
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          child: Icon(
            icon,                // ✅ on utilise bien le paramètre
            size: 44,            // un peu plus grand
            color: AppColors.fog,
          ),
        ),
      ),
    );
  }
}

// ── Colonne jour : date (non-scalée) + corps (scalé) ───────────────────────
class _DayColumnItem extends StatelessWidget {
  final String dateLabel;
  final String? address;
  final VoidCallback? onAddAddress;
  final double scale;

  const _DayColumnItem({
    required this.dateLabel,
    required this.address,
    required this.scale,
    this.onAddAddress,
  });

  @override
  Widget build(BuildContext context) {
    final hasAddress = (address != null && address!.trim().isNotEmpty);

    // échelle bornée pour éviter des tailles extrêmes
    final s = scale.clamp(1.0, 1.6);
    // font-size de la date qui suit l’échelle (discret mais lisible)
    final dateFontSize = 11.0 + (s - 1.0) * 3.5; // ~11 → ~13.1 pour s=1.6
    final dateWeight   = s > 1.35 ? FontWeight.w700 : FontWeight.w600;
    final dateColor    = AppColors.fog;

    return SizedBox(
      width: 110,
      height: 170,
      child: Column(
        children: [
          // Date : grandit par la taille de police (sans transform, donc jamais “coupée”)
          Text(
            dateLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: dateFontSize,
              fontWeight: dateWeight,
              color: dateColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),

          // Corps (maison + adresse) — lui reste sous Transform.scale
          Expanded(
            child: Transform.scale(
              scale: s,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  const Icon(Icons.home_rounded, color: AppColors.fog, size: 32),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: hasAddress
                          ? Text(
                        address!,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 6,
                          fontWeight: FontWeight.w500,
                          color: AppColors.fog,
                          height: 1.2,
                        ),
                      )
                          : TextButton.icon(
                        onPressed: onAddAddress,
                        icon: const Icon(Icons.add, size: 8, color: AppColors.fog),
                        label: Text(
                          context.l10n.tripNoAddress, // ⬅️ i18n
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: AppColors.fog,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: AppColors.fog,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

