//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/address_search_sheet.dart
// Author : Morice
//---------------------------------------------------------------------------


// features/planning/presentation/widgets/address_search_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/core/l10n/l10n_ext.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/app/di/service_locator.dart';

// Cubit + state
import 'package:texas_buddy/features/planning/presentation/cubits/address_search_cubit.dart';
import 'package:texas_buddy/features/planning/presentation/cubits/planning_overlay_cubit.dart';

// Usecases
import 'package:texas_buddy/features/planning/domain/usecases/address_search/search_address_suggestions_usecase.dart';
import 'package:texas_buddy/features/planning/domain/usecases/address_search/select_address_usecase.dart';
import 'package:texas_buddy/features/planning/domain/usecases/trips/update_tripday_address_usecase.dart';
import 'package:texas_buddy/features/planning/domain/usecases/trips/get_trip_usecase.dart'; // ✅ NEW

class AddressSearchSheet extends StatelessWidget {
  const AddressSearchSheet({
    super.key,
    required this.tripId,     // ✅ NEW
    required this.tripDayId,
  });

  final int tripId;           // ✅ NEW
  final int tripDayId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddressSearchCubit(
        getIt<SearchAddressSuggestionsUseCase>(),
        getIt<SelectAddressUseCase>(),
        getIt<UpdateTripDayAddressUseCase>(),
        getIt<GetTripUseCase>(),
        uiLang: Localizations.localeOf(context).languageCode,
        onTripRefreshed: (trip) {                       // ✅ clé du rafraîchissement
          context.read<PlanningOverlayCubit>().applyRefreshedTrip(trip);
        },
      ),
      child: _SheetInner(tripId: tripId, tripDayId: tripDayId),
    );
  }
}

class _SheetInner extends StatelessWidget {
  const _SheetInner({required this.tripId, required this.tripDayId});

  final int tripId;
  final int tripDayId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .6,
      minChildSize: .4,
      maxChildSize: .9,
      builder: (_, controller) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle + Title
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  l10n.addressFormTitle, // ex: “Set hotel address”
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // --- VILLE ---
                BlocBuilder<AddressSearchCubit, AddressSearchState>(
                  buildWhen: (p, n) => p.city != n.city,
                  builder: (context, state) {
                    return TextField(
                      decoration: InputDecoration(
                        labelText: l10n.cityLabel,
                        hintText: l10n.cityHint,
                        border: const OutlineInputBorder(),
                        suffixIcon: state.city.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => context.read<AddressSearchCubit>().setCity(''),
                        )
                            : null,
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (v) => context.read<AddressSearchCubit>().setCity(v),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // --- ADRESSE (désactivée tant que la ville est vide) ---
                BlocBuilder<AddressSearchCubit, AddressSearchState>(
                  buildWhen: (p, n) => p.city != n.city || p.query != n.query,
                  builder: (context, state) {
                    final enabled = state.city.trim().isNotEmpty;
                    return TextField(
                      enabled: enabled,
                      decoration: InputDecoration(
                        labelText: l10n.addressLabel,
                        hintText: enabled ? l10n.addressHint : l10n.fillCityFirst,
                        border: const OutlineInputBorder(),
                        suffixIcon: state.query.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => context.read<AddressSearchCubit>().setQuery(''),
                        )
                            : null,
                      ),
                      onChanged: (v) => context.read<AddressSearchCubit>().setQuery(v),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // --- RÉSULTATS / STATUT ---
                Expanded(
                  child: BlocConsumer<AddressSearchCubit, AddressSearchState>(
                    listenWhen: (p, n) => p.status != n.status && n.status == AddressSearchStatus.error,
                    listener: (context, state) {
                      final msg = state.errorMessage ?? l10n.genericError;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                    },
                    builder: (context, state) {
                      if (state.status == AddressSearchStatus.idle) {
                        return _Hint(text: l10n.typeAtLeast3Chars);
                      }
                      if (state.status == AddressSearchStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.status == AddressSearchStatus.error) {
                        return _Hint(text: state.errorMessage ?? l10n.genericError);
                      }
                      if (state.results.isEmpty) {
                        return _Hint(text: l10n.noResults);
                      }

                      final isSelecting = state.status == AddressSearchStatus.selecting;

                      return Stack(
                        children: [
                          ListView.separated(
                            controller: controller,
                            itemCount: state.results.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (ctx, i) {
                              final s = state.results[i];
                              return ListTile(
                                enabled: !isSelecting,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                                leading: const Icon(Icons.place, color: AppColors.texasBlue),
                                title: Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text(
                                  s.formattedAddress ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () async {
                                  await context.read<AddressSearchCubit>().selectSuggestion(
                                    tripId: tripId,
                                    tripDayId: tripDayId,
                                    suggestion: s,
                                  );
                                  final st = context.read<AddressSearchCubit>().state;
                                  if (st.status == AddressSearchStatus.done && ctx.mounted) {
                                    Navigator.of(ctx).pop();
                                  }
                                },
                              );
                            },
                          ),

                          if (isSelecting)
                            Container(
                              color: Colors.white.withValues(alpha: .6),
                              alignment: Alignment.center,
                              child: const SizedBox(
                                height: 36,
                                width: 36,
                                child: CircularProgressIndicator(strokeWidth: 3),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class _Hint extends StatelessWidget {
  final String text;
  const _Hint({required this.text});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black54),
      ),
    );
  }
}
