//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/widgets/detail_panel.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:texas_buddy/core/l10n/l10n_ext.dart';
import 'package:texas_buddy/core/utils/use_miles.dart';

import '../blocs/detail/detail_panel_bloc.dart';
import 'package:texas_buddy/features/map/presentation/widgets/expandable_text.dart';
import 'package:texas_buddy/features/map/presentation/cubits/map_focus_cubit.dart';
import 'package:texas_buddy/features/map/domain/entities/detail_models.dart';


class DetailPanel extends StatelessWidget {
  final VoidCallback onClose;
  final ScrollController? scrollController;

  const DetailPanel({
    super.key,
    required this.onClose,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<DetailPanelBloc, DetailPanelState>(
      buildWhen: (p, n) => p.runtimeType != n.runtimeType || p != n,
      builder: (context, state) {
        if (state is DetailHidden) return const SizedBox.shrink();

        Widget inner;
        switch (state) {
          case DetailLoading():
            inner = const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            );
          case DetailError(message: final message):
            inner = SizedBox(
              height: 120,
              child: Center(child: Text(message, style: theme.textTheme.bodyMedium)),
            );
          case DetailActivityLoaded(
          entity: final entity,
          travel: final travel,
          focusSource: final focusSource,
          ):
            inner = _ActivityDetailView(
              entity: entity,
              travel: travel,
              focusSource: focusSource,
              onClose: onClose,
            );
          case DetailEventLoaded(
          entity: final entity,
          travel: final travel,
          focusSource: final focusSource,
          ):
            inner = _EventDetailView(
              entity: entity,
              travel: travel,
              focusSource: focusSource,
              onClose: onClose,
            );
          default:
            inner = const SizedBox.shrink();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(top: 8, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: inner,
              ),
            ),
          ],
        );
      },
    );
  }
}

// --- Helpers --------------------------------------------------------------

String _capFirst(String? s) {
  if (s == null || s.isEmpty) return '';
  return s[0].toUpperCase() + s.substring(1);
}

String _formatDuration(dynamic duration) {
  if (duration == null) return '—';
  if (duration is String) return duration;
  if (duration is num) {
    final totalMin = duration.round();
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    if (h > 0) {
      final mm = m.toString().padLeft(2, '0');
      return '$h h $mm';
    }
    return '$totalMin min';
  }
  return duration.toString();
}

String _formatPrice(BuildContext context, dynamic price) {
  if (price == null) return '—';
  if (price is num) {
    final cur = NumberFormat.simpleCurrency(name: 'USD');
    return cur.format(price);
  }
  return price.toString();
}

bool _isByReservation(dynamic e) {
  try {
    return (e as dynamic).isByReservation == true;
  } catch (_) {
    return false;
  }
}

String _fromLabel(BuildContext context, MapFocusSource src) {
  final l10n = context.l10n;
  return switch (src) {
    MapFocusSource.user => l10n.travelFromUser,
    MapFocusSource.tripStep => l10n.travelFromPrevStep,
    MapFocusSource.tripDay => l10n.travelFromHotel,
    MapFocusSource.dallas => l10n.travelFromDallas,
  };
}

Text _travelLine(BuildContext context, TravelInfo? travel, MapFocusSource? src) {
  final l10n = context.l10n;
  final useMiles = useMilesForLocale(Localizations.maybeLocaleOf(context));

  if (travel == null || src == null) return const Text('');

  final distance = formatDistanceFromMeters(
    meters: travel.meters,
    useMiles: useMiles,
    locale: Localizations.maybeLocaleOf(context),
  );

  final duration = formatMinutes(travel.minutes);
  final from = _fromLabel(context, src);

  return Text(
    l10n.travelInfoLine(distance, duration, from),
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.green,
      fontWeight: FontWeight.w600,
    ),
  );
}

// --- Views ----------------------------------------------------------------

class _ActivityDetailView extends StatelessWidget {
  final ActivityDetailEntity entity;
  final TravelInfo? travel;
  final MapFocusSource? focusSource;
  final VoidCallback onClose;

  const _ActivityDetailView({
    required this.entity,
    required this.onClose,
    this.travel,
    this.focusSource,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Titre gros + close
        Row(
          children: [
            Expanded(
              child: Text(
                entity.name,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
          ],
        ),

        // ✅ Travel line (vert)
        if (travel != null && focusSource != null) ...[
          const SizedBox(height: 2),
          _travelLine(context, travel, focusSource),
        ],

        // PrimaryCategory + ❤️ si staff_favorite
        if (entity.primaryCategory != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.label_rounded, size: 18),
              const SizedBox(width: 8),
              Text(
                _capFirst(entity.primaryCategory!.name),
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (entity.staffFavorite == true) ...[
                const SizedBox(width: 8),
                const Icon(Icons.favorite, size: 18, color: Colors.red),
              ],
            ],
          ),
        ],

        const SizedBox(height: 8),

        Wrap(
          spacing: 6,
          runSpacing: -8,
          children: entity.categories
              .take(4)
              .map<Widget>((c) => Chip(label: Text(_capFirst(c.name))))
              .toList(),
        ),

        if (_isByReservation(entity)) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 6),
              Text(
                context.l10n.reservationRequired, // ✅ ajoute une clé l10n si tu veux
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],

        const SizedBox(height: 8),

        if (entity.image != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(entity.image!, height: 140, fit: BoxFit.cover),
          ),

        const SizedBox(height: 8),

        if (entity.description != null && entity.description!.isNotEmpty)
          ExpandableText(
            entity.description!,
            trimLines: 3,
            style: theme.textTheme.bodyMedium,
          ),

        const SizedBox(height: 10),

        Row(
          children: [
            const Icon(Icons.attach_money, size: 18),
            const SizedBox(width: 6),
            Text(
              '${context.l10n.averagePriceLabel} ${_formatPrice(context, entity.price)}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),

        const SizedBox(height: 6),

        Row(
          children: [
            const Icon(Icons.timelapse, size: 18),
            const SizedBox(width: 6),
            Text(
              '${context.l10n.averageDurationLabel} ${_formatDuration(entity.duration)}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),

        const SizedBox(height: 6),

        if (entity.website != null && entity.website!.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.public, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  entity.website!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 6),

        if (entity.currentPromotion != null)
          Row(
            children: [
              const Icon(Icons.local_offer),
              const SizedBox(width: 6),
              Text(entity.currentPromotion!.title),
            ],
          ),
      ],
    );
  }
}

class _EventDetailView extends StatelessWidget {
  final EventDetailEntity entity;
  final TravelInfo? travel;
  final MapFocusSource? focusSource;
  final VoidCallback onClose;

  const _EventDetailView({
    required this.entity,
    required this.onClose,
    this.travel,
    this.focusSource,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final DateTime? start = entity.start?.toLocal();
    final DateTime? end = entity.end?.toLocal();
    final String locale = Localizations.localeOf(context).toString();
    final DateFormat df = DateFormat.yMMMd(locale);

    bool isBetweenToday(DateTime? s, DateTime? e) {
      if (s == null || e == null) return false;
      DateTime dOnly(DateTime d) => DateTime(d.year, d.month, d.day);
      final today = dOnly(DateTime.now());
      return dOnly(s).isBefore(today.add(const Duration(days: 1))) &&
          dOnly(e).isAfter(today.subtract(const Duration(days: 1)));
    }

    final bool active = isBetweenToday(start, end);
    final Color dateColor = active ? Colors.green : Colors.red;
    final TextStyle dateStyle = theme.textTheme.bodyMedium!.copyWith(
      color: dateColor,
      fontWeight: FontWeight.w600,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Titre gros + close
        Row(
          children: [
            Expanded(
              child: Text(
                entity.name,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
          ],
        ),

        // ✅ Travel line (vert)
        if (travel != null && focusSource != null) ...[
          const SizedBox(height: 2),
          _travelLine(context, travel, focusSource),
        ],

        // Dates
        if (start != null && end != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule, size: 18),
              const SizedBox(width: 6),
              Text('${df.format(start)} — ${df.format(end)}', style: dateStyle),
            ],
          ),
        ] else if (start != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule, size: 18),
              const SizedBox(width: 6),
              Text(df.format(start), style: dateStyle),
            ],
          ),
        ],

        const SizedBox(height: 6),

        if (entity.primaryCategory != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.label_rounded, size: 18),
              const SizedBox(width: 8),
              Text(
                _capFirst(entity.primaryCategory!.name),
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (entity.staffFavorite == true) ...[
                const SizedBox(width: 8),
                const Icon(Icons.favorite, size: 18, color: Colors.red),
              ],
            ],
          ),
        ],

        const SizedBox(height: 8),

        Wrap(
          spacing: 6,
          runSpacing: -8,
          children: entity.categories
              .take(4)
              .map<Widget>((c) => Chip(label: Text(_capFirst(c.name))))
              .toList(),
        ),

        if (_isByReservation(entity)) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 6),
              Text(
                context.l10n.reservationRequired,
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],

        const SizedBox(height: 8),

        if (entity.image != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(entity.image!, height: 140, fit: BoxFit.cover),
          ),

        const SizedBox(height: 8),

        if (entity.description != null && entity.description!.isNotEmpty)
          ExpandableText(
            entity.description!,
            trimLines: 3,
            style: theme.textTheme.bodyMedium,
          ),

        const SizedBox(height: 10),

        Row(
          children: [
            const Icon(Icons.attach_money, size: 18),
            const SizedBox(width: 6),
            Text(
              '${context.l10n.averagePriceLabel} ${_formatPrice(context, entity.price)}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),

        const SizedBox(height: 6),

        Row(
          children: [
            const Icon(Icons.timelapse, size: 18),
            const SizedBox(width: 6),
            Text(
              '${context.l10n.averageDurationLabel} ${_formatDuration(entity.duration)}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),

        const SizedBox(height: 6),

        if (entity.website != null && entity.website!.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.public, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  entity.website!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 6),

        if (entity.currentPromotion != null)
          Row(
            children: [
              const Icon(Icons.local_offer),
              const SizedBox(width: 6),
              Text(entity.currentPromotion!.title),
            ],
          ),
      ],
    );
  }
}
