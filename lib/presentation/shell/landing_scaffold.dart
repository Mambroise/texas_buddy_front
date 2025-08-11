
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

/// Shell hôte des onglets.
/// - Onglets persistants via IndexedStack
/// - Un Navigator par onglet pour conserver la stack interne
class LandingScaffold extends StatefulWidget {
  const LandingScaffold({super.key});

  @override
  State<LandingScaffold> createState() => _LandingScaffoldState();
}

class _LandingScaffoldState extends State<LandingScaffold> {
  int _currentIndex = 0;

  // Clés de navigateurs par onglet (permettent pop() ciblé)
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
      return false; // on consomme le back pour pop l'écran interne
    }
    return true; // sinon, laisser Android/iOS gérer (sortie app ou parent route)
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Texas Buddy'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: AppColors.texasBlue),
            onPressed: () {
              // TODO: ouvrir Drawer / Menu latéral
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: AppColors.texasBlue),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UserPage()),
                );
              },
            ),
          ],
        ),

        // ✅ Les onglets sont montés en permanence
        body: IndexedStack(index: _currentIndex, children: _tabs),

        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppColors.texasBlue,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Planning'),
            BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Community'),
          ],
        ),
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
