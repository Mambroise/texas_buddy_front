
//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : presentation/shell/landing_scaffold.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/features/map/presentation/pages/map_page.dart';
import 'package:texas_buddy/features/planning/presentation/pages/planning_page.dart';
import 'package:texas_buddy/features/community/presentation/pages/community_page.dart';
import 'package:texas_buddy/features/user/presentation/pages/user_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/features/planning/presentation/cubit/planning_overlay_cubit.dart';
import 'package:texas_buddy/features/map/presentation/blocs/nearby/nearby_bloc.dart';
import 'package:texas_buddy/app/di/service_locator.dart';
import 'package:texas_buddy/features/map/presentation/cubits/category_filter_cubit.dart';


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
    // L’onglet Planning peut rester (pour plus tard) MAIS on ne l’utilise pas ici.
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


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoryFilterCubit>(create: (_) => CategoryFilterCubit()),
        BlocProvider<PlanningOverlayCubit>(create: (_) => PlanningOverlayCubit()),
        BlocProvider<NearbyBloc>(create: (_) => getIt<NearbyBloc>()),
      ],
      child: Builder( // <-- garder le Builder pour disposer d'un context sous les providers
        builder: (ctx) {
          return PopScope(
            canPop: !(() {
              final hasInnerPop = _navKeys[_currentIndex].currentState?.canPop() ?? false;
              final overlayVisible = ctx.read<PlanningOverlayCubit>().state.visible;
              return overlayVisible || hasInnerPop;
            }()),
            onPopInvoked: (didPop) {
              if (didPop) return; // le système a déjà pop (rien à faire)

              final cubit = ctx.read<PlanningOverlayCubit>();
              final overlayVisible = cubit.state.visible;
              final currentNavigator = _navKeys[_currentIndex].currentState;

              // 1) Si l’overlay Planning est ouvert, on le ferme et on consomme le back.
              if (overlayVisible) {
                cubit.hide();
                return;
              }

              // 2) Sinon, si l’onglet courant a une stack interne, on pop la page interne.
              if (currentNavigator?.canPop() ?? false) {
                currentNavigator!.pop();
                return;
              }

              // 3) Sinon, rien à gérer : on laissera le prochain back sortir de l’app.
              // (canPop était true dans ce cas, donc on n’atteindra pas ce bloc)
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Texas Buddy'),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.texasBlue),
                  onPressed: () {},
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person, color: AppColors.texasBlue),
                    onPressed: () {
                      Navigator.of(ctx).push(
                        MaterialPageRoute(builder: (_) => const UserPage()),
                      );
                    },
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
                      const BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.calendar_month,
                          color: isPlanningActive ? Colors.white : Colors.white70,
                        ),
                        label: 'Planning',
                      ),
                      const BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Community'),
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



/// Navigator interne à un onglet. Conserve la stack et l'état du tab.
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
