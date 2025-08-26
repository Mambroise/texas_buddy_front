import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import '../cubits/category_filter_cubit.dart';

class CategoryChipsBar extends StatelessWidget {
  const CategoryChipsBar({super.key, required this.onChanged});
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final String locKey = _localeKey(Localizations.localeOf(context));
    final Color blue = AppColors.texasBlue;

    const chips = <ChipSpec>[
      ChipSpec(
        id: '*',
        labels: {'en': 'All', 'fr': 'Tous', 'es_MX': 'Todos'},
        categories: <String>{},
      ),
      // Nouveau chip "Events"
      ChipSpec(
        id: 'events',
        labels: {'en': 'Events', 'fr': 'Évènements', 'es_MX': 'Eventos'},
        categories: <String>{},
        typeOnly: 'event', // <<< important
      ),
      ChipSpec(
        id: 'eat',
        labels: {'en': 'Eat', 'fr': 'Manger', 'es_MX': 'Comer'},
        categories: <String>{'fa-utensils','fa-burger','fa-hot-pepper','fa-pizza-slice','fa-ice-cream'},
      ),
      ChipSpec(
        id: 'drink',
        labels: {'en': 'Drink', 'fr': 'Boire', 'es_MX': 'Beber'},
        categories: <String>{'fa-beer-mug','fa-wine-glass','fa-cocktail','fa-coffee','fa-glass-cheers'},
      ),
      ChipSpec(
        id: 'night',
        labels: {'en': 'Go out', 'fr': 'Sortir', 'es_MX': 'Salir'},
        categories: <String>{'fa-nightlife','fa-music','fa-dance','fa-theater-masks'},
      ),
      ChipSpec(
        id: 'fun',
        labels: {'en': 'Have fun', 'fr': 'S’amuser', 'es_MX': 'Divertirse'},
        categories: <String>{'fa-fun','fa-gamepad','fa-bowling','fa-film','fa-park'},
      ),
      ChipSpec(
        id: 'free',
        labels: {'en': 'Free', 'fr': 'Gratuit', 'es_MX': 'Gratis'},
        categories: <String>{'fa-gift'},
      ),
    ];

    return SafeArea(
      top: true, bottom: false,
      child: SizedBox(
        height: 44,
        child: BlocBuilder<CategoryFilterCubit, Set<String>>(
          builder: (context, selected) {
            final eventsOnly = selected.contains(CategoryFilterCubit.typeEventToken);

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              scrollDirection: Axis.horizontal,
              itemCount: chips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final spec = chips[i];
                final isAll = spec.id == '*';
                final isTypeOnly = spec.typeOnly != null;
                final label = spec.labels[locKey] ?? spec.labels['en']!;

                final bool active = isAll
                    ? (!eventsOnly && selected.isEmpty)
                    : isTypeOnly
                    ? eventsOnly
                    : spec.categories.any(selected.contains);

                return FilterChip(
                  label: Text(label, style: TextStyle(color: blue, fontWeight: FontWeight.w600)),
                  showCheckmark: false,
                  backgroundColor: Colors.white,
                  selectedColor: Colors.white,
                  elevation: 2,
                  pressElevation: 3,
                  shadowColor: Colors.black26,
                  side: BorderSide(
                    color: active ? blue : blue.withValues(alpha: 0.35),
                    width: active ? 1.6 : 1.0,
                  ),
                  shape: const StadiumBorder(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  selected: active,
                  onSelected: (_) {
                    final cubit = context.read<CategoryFilterCubit>();
                    if (isAll) {
                      cubit.clear();                // all: reset (no categories, no event mode)
                    } else if (isTypeOnly) {
                      cubit.setEventsOnly(!eventsOnly); // toggle events-only
                    } else {
                      cubit.setEventsOnly(false);   // leave type mode
                      cubit.toggleMany(spec.categories);
                    }
                    onChanged(); // MapPage will: local render + server fetch
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ChipSpec {
  final String id;
  final Map<String, String> labels; // {'en':..., 'fr':..., 'es_MX':...}
  final Set<String> categories;
  final String? typeOnly; // 'event' for the Events chip, null otherwise
  const ChipSpec({
    required this.id,
    required this.labels,
    required this.categories,
    this.typeOnly,
  });
}

String _localeKey(Locale l) {
  if (l.languageCode == 'fr') return 'fr';
  if (l.languageCode == 'es' && (l.countryCode?.toUpperCase() == 'MX')) return 'es_MX';
  return 'en';
}
