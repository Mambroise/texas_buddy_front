//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : presentation/shell/landing_scaffold.dart
// Author : Morice
//---------------------------------------------------------------------------

/*
==============================================================================
LandingScaffold — Rôle et points clés
==============================================================================

🎯 À quoi sert cette page ?
- C’est le "Shell" principal de l’app après login : elle héberge la navigation
  principale (onglets) + l’AppBar globale, et injecte les blocs/cubits nécessaires
  au fonctionnement Map / Planning / Community.
- Elle est conçue pour une navigation fluide avec onglets persistants :
  chaque onglet conserve son état (scroll, navigation interne, etc.).

🏗️ Structure principale
1) MultiBlocProvider
   - Centralise l’injection des blocs/cubits nécessaires aux features visibles
     dans le shell :
     - Map (NearbyBloc, AllEventsBloc, MapModeCubit, MapFocusCubit, filters…)
     - Planning (PlanningOverlayCubit, TripsCubit)
     - Détail (DetailPanelBloc) pour afficher les détails d’une activité/événement

2) IndexedStack + Navigators par onglet
   - body: IndexedStack(index: _currentIndex, children: _tabs)
   - Chaque onglet est un Navigator séparé (_TabNavigator) avec keep alive :
     ✅ les pages restent montées
     ✅ les piles de navigation internes restent indépendantes

3) AppBar globale (toujours visible)
   - Bouton menu (leading) :
     - ouvre un BottomSheet (MapModeMenuSheet)
     - permet de choisir le mode de carte "events" ou "nearby"
     - applique le choix via MapModeCubit
   - Bouton profil (actions) :
     - ouvre UserPage via MaterialPageRoute

4) PlanningOverlay (comportement spécial)
   - Le bouton "Planning" dans la BottomNavigationBar ne change pas d’onglet :
     - il toggle l’overlay (PlanningOverlayCubit)
     - et force l’index à 0 (Map) pour rester sur la carte en arrière-plan
   - Visuellement, l’icône planning reflète l’état (active/inactive).

5) Gestion du bouton "Retour" (Android/back)
   - PopScope empêche de quitter la page si :
     - l’overlay planning est ouvert, OU
     - le Navigator interne de l’onglet courant peut pop
   - Logique d’ordre :
     1) si overlay visible => on le ferme
     2) sinon si navigation interne possible => pop()
     3) sinon => back système (canPop true)

6) Sécurité de chargement des Trips (post-frame)
   - addPostFrameCallback :
     - attend que le contexte soit prêt (et donc DI + token prêts)
     - si aucune requête n’est en cours et la liste est vide => fetchAll(force: true)
   - Objectif : éviter un shell vide si l’utilisateur arrive ici sans trips chargés.

📌 Pourquoi c’est important ?
- Ce fichier est le "hub" UI : il orchestre navigation, injection d’états,
  et interactions Map ↔ Planning ↔ Detail.
- Il reflète l’architecture "onglets persistants + overlay planning" décrite
  dans la clean architecture du projet. :contentReference[oaicite:0]{index=0}
- Il s’aligne avec la vision globale de Texas Buddy : carte temps réel, planning,
  communauté, profil utilisateur. :contentReference[oaicite:1]{index=1}
==============================================================================
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/features/map/presentation/pages/map_page.dart';
import 'package:texas_buddy/features/planning/presentation/pages/planning_page.dart';
import 'package:texas_buddy/features/community/presentation/pages/community_page.dart';
import 'package:texas_buddy/features/user/presentation/pages/user_page.dart';

import 'package:texas_buddy/features/planning/presentation/cubits/planning_overlay_cubit.dart';
import 'package:texas_buddy/features/planning/presentation/cubits/trips_cubit.dart';
import 'package:texas_buddy/features/map/presentation/blocs/nearby/nearby_bloc.dart';
import 'package:texas_buddy/features/map/presentation/blocs/all_events/all_events_bloc.dart';
import 'package:texas_buddy/features/map/presentation/cubits/category_filter_cubit.dart';
import 'package:texas_buddy/features/map/presentation/cubits/map_mode_cubit.dart';
import 'package:texas_buddy/features/map/presentation/widgets/map_mode_menu_sheet.dart';
import 'package:texas_buddy/features/map/presentation/cubits/map_focus_cubit.dart';
import 'package:texas_buddy/features/planning/presentation/blocs/trips/trips_state.dart';

import 'package:texas_buddy/features/map/presentation/blocs/detail/detail_panel_bloc.dart';
import 'package:texas_buddy/features/map/domain/usecases/get_activity_detail.dart';
import 'package:texas_buddy/features/map/domain/usecases/get_event_detail.dart';
import 'package:texas_buddy/features/planning/domain/usecases/travel/compute_travel.dart';

import 'package:texas_buddy/app/di/service_locator.dart';
import 'package:texas_buddy/features/user/domain/usecases/get_cached_user_usecase.dart';
import 'package:texas_buddy/features/user/domain/usecases/fetch_and_cache_me_usecase.dart';
import 'package:texas_buddy/features/user/presentation/sheets/interests_sheet.dart';

// <-- L10n extension
import 'package:texas_buddy/core/l10n/l10n_ext.dart';

class LandingScaffold extends StatefulWidget {
  const LandingScaffold({super.key});
  @override
  State<LandingScaffold> createState() => _LandingScaffoldState();
}

class _LandingScaffoldState extends State<LandingScaffold> {
  int _currentIndex = 0;
  bool _didCheckInterests = false;
  bool _sheetOpen = false;

  final _getCachedUser = getIt<GetCachedUserUseCase>();
  final _fetchMeAndCache = getIt<FetchAndCacheMeUseCase>();

  final _navKeys = <GlobalKey<NavigatorState>>[
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  late final List<_TabNavigator> _tabs = [
    _TabNavigator(key: _navKeys[0], child: const MapPage()),
    _TabNavigator(key: _navKeys[1], child: const PlanningPage()),
    _TabNavigator(key: _navKeys[2], child: const CommunityPage()),
  ];


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeOpenInterestsSheet(context);
    });
  }

  Future<void> _maybeOpenInterestsSheet(BuildContext context) async {
    if (_didCheckInterests) return;
    _didCheckInterests = true;

    if (!mounted) return;

    try {
      var me = await _getCachedUser();

      // si le cache est vide (ou pas prêt), on retente un fetch non bloquant
      me ??= await _fetchMeAndCache();

      final interests = me.interestCategoryIds; // <- adapte si le champ s’appelle autrement
      final hasInterests = me.interestCategoryIds.isNotEmpty;

      if (hasInterests) return;
      if (_sheetOpen) return;

      final route = ModalRoute.of(context);
      if (route == null || !route.isCurrent) return;

      _sheetOpen = true;

      await showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => const InterestsSheet(),
      );
    } catch (_) {
      // non-bloquant
    } finally {
      _sheetOpen = false;
    }
  }

  Future<void> _openMapMenu(BuildContext ctx) async {
    final choice = await showModalBottomSheet<String>(
      context: ctx,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => const MapModeMenuSheet(),
    );

    if (choice == 'events') {
      ctx.read<MapModeCubit>().setEvents();
    } else if (choice == 'nearby') {
      ctx.read<MapModeCubit>().setNearby();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoryFilterCubit>(create: (_) => CategoryFilterCubit()),
        BlocProvider<PlanningOverlayCubit>(
          create: (_) => getIt<PlanningOverlayCubit>(),
        ),
        BlocProvider<NearbyBloc>(create: (_) => getIt<NearbyBloc>()),
        BlocProvider<AllEventsBloc>(create: (_) => getIt<AllEventsBloc>()),
        BlocProvider<MapModeCubit>(create: (_) => MapModeCubit()),
        BlocProvider(create: (_) => getIt<MapFocusCubit>()),
        BlocProvider<DetailPanelBloc>(
          create: (ctx) => DetailPanelBloc(
            getActivity: getIt<GetActivityDetail>(),
            getEvent: getIt<GetEventDetail>(),
            mapFocusCubit: ctx.read<MapFocusCubit>(),
            computeTravel: getIt<ComputeTravel>(),
          ),
        ),

        BlocProvider<TripsCubit>(
          create: (_) => getIt<TripsCubit>(),
        ),

      ],
      child: Builder(
        builder: (ctx) {
          // ⚑ Assure le fetch quand le contexte est prêt et le token dispo
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final cubit = ctx.read<TripsCubit>();
            final st = cubit.state;
            final isLoading = st.fetchStatus == TripFetchStatus.loading;

            // Filet de sécurité: relance si vide & pas déjà en cours
            if (!isLoading && st.trips.isEmpty) {
              cubit.fetchAll(force: true);
            }
          });

          return PopScope(
            canPop: !(() {
              final hasInnerPop = _navKeys[_currentIndex].currentState?.canPop() ?? false;
              final overlayVisible = ctx.read<PlanningOverlayCubit>().state.visible;
              return overlayVisible || hasInnerPop;
            }()),
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;

              final cubit = ctx.read<PlanningOverlayCubit>();
              final overlayVisible = cubit.state.visible;
              final currentNavigator = _navKeys[_currentIndex].currentState;

              if (overlayVisible) {
                cubit.hide();
                return;
              }
              if (currentNavigator?.canPop() ?? false) {
                currentNavigator!.pop();
                return;
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(l10n.appTitle),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.texasBlue),
                  onPressed: () => _openMapMenu(ctx),
                  tooltip: l10n.mapTab, // petit plus d’accessibilité
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person, color: AppColors.texasBlue),
                    onPressed: () {
                      Navigator.of(ctx).push(
                        MaterialPageRoute(builder: (_) => const UserPage()),
                      );
                    },
                    tooltip: l10n.profile,
                  ),
                ],
              ),
              body: IndexedStack(index: _currentIndex, children: _tabs),
              bottomNavigationBar: BlocBuilder<PlanningOverlayCubit, PlanningOverlayState>(
                builder: (ctx, ovr) {
                  final isPlanningActive = ovr.visible;
                  return BottomNavigationBar(
                    backgroundColor: AppColors.texasBlue,
                    currentIndex: _currentIndex,
                    selectedItemColor: Colors.white,
                    unselectedItemColor: Colors.white70,
                    onTap: (i) {
                      const planningIndex = 1;
                      if (i == planningIndex) {
                        ctx.read<PlanningOverlayCubit>().toggleOverlay();
                        setState(() => _currentIndex = 0);
                        return;
                      }
                      setState(() => _currentIndex = i);
                    },
                    items: [
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.map),
                        label: l10n.mapTab,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.calendar_month,
                          color: isPlanningActive ? Colors.white : Colors.white70,
                        ),
                        label: l10n.planningTab,
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.group),
                        label: l10n.communityTab,
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// (inchangé)
class _TabNavigator extends StatefulWidget {
  final Widget child;
  const _TabNavigator({super.key, required this.child});
  @override
  State<_TabNavigator> createState() => _TabNavigatorState();
}
class _TabNavigatorState extends State<_TabNavigator>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => widget.child,
        settings: settings,
      ),
    );
  }
}
