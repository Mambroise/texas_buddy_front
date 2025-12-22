import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/app/di/service_locator.dart';
import 'package:texas_buddy/core/l10n/l10n_ext.dart';
import 'package:texas_buddy/features/user/domain/usecases/get_cached_user_usecase.dart';
import 'package:texas_buddy/features/user/presentation/cubits/interests_cubit.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/core/utils/category_icon_mapper.dart';


class InterestsSheet extends StatelessWidget {
  const InterestsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final media = MediaQuery.of(context);
    final bottomSafe = media.viewPadding.bottom;     // ✅ navbar système
    final keyboard = media.viewInsets.bottom;

    return BlocProvider(
      create: (_) {
        // pré-sélection = intérêts actuels du user (cache)
        final me = getIt<GetCachedUserUseCase>();
        return InterestsCubit(
          fetch: getIt(),
          save: getIt(),
          fetchMe: getIt(),
          preselected: <int>{}, // on branchera la vraie pré-sélection ensuite si tu veux
        )..load();
      },
      child: BlocListener<InterestsCubit, InterestsState>(
    listenWhen: (p, n) => p.saveStatus != n.saveStatus,
    listener: (ctx, st) {
      if (st.saveStatus == InterestsSaveStatus.success) {
        Navigator.of(context).pop();
      } else if (st.saveStatus == InterestsSaveStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.interestsSaveError)),
        );
      }
    },
    child: Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + bottomSafe + keyboard,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.myInterests, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(l10n.interestsSubtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),

          BlocBuilder<InterestsCubit, InterestsState>(
            buildWhen: (p, n) => p.query != n.query,
            builder: (ctx, st) {
              return TextField(
                onChanged: ctx.read<InterestsCubit>().setQuery,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10n.search,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          const Divider(),

          Flexible(
            child: BlocBuilder<InterestsCubit, InterestsState>(
              builder: (ctx, st) {
                if (st.status == InterestsStatus.loading) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Text(l10n.interestsLoading),
                      ],
                    ),
                  );
                }

                if (st.status == InterestsStatus.failure) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Text(l10n.interestsLoadError),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => ctx.read<InterestsCubit>().load(),
                        child: Text(l10n.interestsRetry),
                      ),
                    ],
                  );
                }

                final q = st.query.trim().toLowerCase();
                final filtered = (q.isEmpty)
                    ? st.all
                    : st.all.where((c) {
                  final n = c.name.toLowerCase();
                  final d = (c.description ?? '').toLowerCase();
                  return n.contains(q) || d.contains(q);
                }).toList();

                if (filtered.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(l10n.noResults), // si tu l’as déjà; sinon remplace
                  );
                }

                return SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final cat in filtered)
                        _InterestChip(
                          name: cat.name,
                          iconKey: cat.icon ?? cat.name, // icon backend si dispo, sinon fallback sur name
                          selected: st.selectedIds.contains(cat.id),
                          onTap: () => ctx.read<InterestsCubit>().toggle(cat.id),
                        ),

                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          BlocBuilder<InterestsCubit, InterestsState>(
            buildWhen: (p, n) => p.selectedIds.length != n.selectedIds.length,
            builder: (ctx, st) {
              return Row(
                children: [
// ✅ PLUS TARD : texte seul, aucun fond, aucun border
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.texasBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(), // ✅ demi-cercles
                      ),
                      child: Text(
                        l10n.interestsSkip,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

// ✅ ENREGISTRER : fond bleu, blanc, demi-cercles
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (st.selectedIds.isEmpty || st.saveStatus == InterestsSaveStatus.saving)
                          ? null
                          : () => ctx.read<InterestsCubit>().save(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.texasBlue,
                        foregroundColor: AppColors.whiteGlow,
                        disabledBackgroundColor: AppColors.texasBlue.withValues(alpha: 0.35),
                        disabledForegroundColor: AppColors.whiteGlow.withValues(alpha: 0.7),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder(),
                      ),
                      child: st.saveStatus == InterestsSaveStatus.saving
                          ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.whiteGlow,
                        ),
                      )
                          : Text(
                        '${l10n.interestsSave} (${st.selectedIds.length})',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteGlow,
                        ),
                      ),

                    ),
                  ),
                ],
              );

            },
          ),
        ],
      ),
    ),
    ),

    );
  }
}

class _InterestChip extends StatelessWidget {
  final String name;
  final String iconKey;
  final bool selected;
  final VoidCallback onTap;

  const _InterestChip({
    required this.name,
    required this.iconKey,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = CategoryIconMapper.map(iconKey);

    // Couleurs “Texas”
    final bg = selected ? AppColors.texasRedGlow70 : AppColors.texasBlue;
    final fg = AppColors.whiteGlow;
    final check = AppColors.white;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 8),
            Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check_circle, size: 16, color: check), // ✅ V rouge
            ],
          ],
        ),
      ),
    );
  }
}
