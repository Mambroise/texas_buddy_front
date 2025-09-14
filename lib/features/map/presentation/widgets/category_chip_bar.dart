//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/map/presentation/widgets/category_chip_bar.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import '../cubits/category_filter_cubit.dart';

// L10n
import 'package:texas_buddy/core/l10n/l10n_ext.dart';

class CategoryChipsBar extends StatelessWidget {
  const CategoryChipsBar({super.key, required this.onChanged});
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final Color blue = AppColors.texasBlue;
    final Color activeColor = AppColors.texasRed ;
    final Color inactiveColor = AppColors.texasBlue;

    // Labels 100% localisés via ARB
    final chips = <ChipSpec>[
      ChipSpec(
        id: '*',
        label: l10n.categoryAll,
        categories: const <String>{},
      ),
      ChipSpec(
        id: 'events',
        label: l10n.categoryEvents,
        categories: const <String>{},
        typeOnly: 'event', // important
      ),
      ChipSpec(
        id: 'eat',
        label: l10n.categoryEat,
        categories: const <String>{
          'fa-utensils','fa-burger','fa-hot-pepper','fa-pizza-slice','fa-ice-cream'
        },
      ),
      ChipSpec(
        id: 'drink',
        label: l10n.categoryDrink,
        categories: const <String>{
          'fa-beer-mug','fa-wine-glass','fa-cocktail','fa-coffee','fa-glass-cheers'
        },
      ),
      ChipSpec(
        id: 'night',
        label: l10n.categoryGoOut,
        categories: const <String>{'fa-nightlife','fa-music','fa-dance','fa-theater-masks'},
      ),
      ChipSpec(
        id: 'fun',
        label: l10n.categoryHaveFun,
        categories: const <String>{'fa-fun','fa-gamepad','fa-bowling','fa-film','fa-park'},
      ),
      ChipSpec(
        id: 'free',
        label: l10n.categoryFree,
        categories: const <String>{'fa-gift'},
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

                final bool active = isAll
                    ? (!eventsOnly && selected.isEmpty)
                    : isTypeOnly
                    ? eventsOnly
                    : spec.categories.any(selected.contains);

                return FilterChip(
                  label: Text(
                    spec.label,
                    style: TextStyle(
                      color: active ? activeColor : inactiveColor,  // ✅ label rouge si actif
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  showCheckmark: false,
                  backgroundColor: Colors.white,
                  selectedColor: Colors.white,
                  elevation: 2,
                  pressElevation: 3,
                  shadowColor: Colors.black26,
                  side: BorderSide(
                    color: active
                        ? activeColor                                 // ✅ bordure rouge si actif
                        : inactiveColor.withValues(alpha: 0.35),
                    width: active ? 1.6 : 1.0,
                  ),
                  shape: const StadiumBorder(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  selected: active,
                  onSelected: (_) {
                    final cubit = context.read<CategoryFilterCubit>();
                    if (isAll) {
                      cubit.clear();
                    } else if (isTypeOnly) {
                      cubit.setEventsOnly(!eventsOnly);
                    } else {
                      cubit.setEventsOnly(false);
                      cubit.toggleMany(spec.categories);
                    }
                    onChanged();
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
  final String label;       // <— string localisé
  final Set<String> categories;
  final String? typeOnly;   // 'event' pour le chip Events, sinon null
  const ChipSpec({
    required this.id,
    required this.label,
    required this.categories,
    this.typeOnly,
  });
}
