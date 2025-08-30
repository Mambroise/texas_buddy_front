//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : presentation/shell/landing_scaffold.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/features/map/presentation/pages/map_page.dart';
import 'package:texas_buddy/features/planning/presentation/pages/planning_page.dart';
import 'package:texas_buddy/features/community/presentation/pages/community_page.dart';
import 'package:texas_buddy/features/user/presentation/pages/user_page.dart';

import 'package:texas_buddy/features/planning/presentation/cubit/planning_overlay_cubit.dart';
import 'package:texas_buddy/features/map/presentation/blocs/nearby/nearby_bloc.dart';
import 'package:texas_buddy/features/map/presentation/blocs/all_events/all_events_bloc.dart';
import 'package:texas_buddy/features/map/presentation/cubits/category_filter_cubit.dart';
import 'package:texas_buddy/features/map/presentation/cubits/map_mode_cubit.dart';
import 'package:texas_buddy/features/map/presentation/widgets/map_mode_menu_sheet.dart';

import 'package:texas_buddy/app/di/service_locator.dart';

// <-- L10n extension
import 'package:texas_buddy/core/l10n/l10n_ext.dart';

class LandingScaffold extends StatefulWidget {
  const LandingScaffold({super.key});
  @override
  State<LandingScaffold> createState() => _LandingScaffoldState();
}

class _LandingScaffoldState extends State<LandingScaffold> {
  int _currentIndex = 0;

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

  Future<bool> _onWillPop() async {
    final NavigatorState? currentNavigator = _navKeys[_currentIndex].currentState;
    if (currentNavigator?.canPop() ?? false) {
      currentNavigator!.pop();
      return false;
    }
    return true;
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
        BlocProvider<PlanningOverlayCubit>(create: (_) => PlanningOverlayCubit()),
        BlocProvider<NearbyBloc>(create: (_) => getIt<NearbyBloc>()),
        BlocProvider<AllEventsBloc>(create: (_) => getIt<AllEventsBloc>()),
        BlocProvider<MapModeCubit>(create: (_) => MapModeCubit()),
      ],
      child: Builder(
        builder: (ctx) {
          return PopScope(
            canPop: !(() {
              final hasInnerPop = _navKeys[_currentIndex].currentState?.canPop() ?? false;
              final overlayVisible = ctx.read<PlanningOverlayCubit>().state.visible;
              return overlayVisible || hasInnerPop;
            }()),
            onPopInvoked: (didPop) {
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
