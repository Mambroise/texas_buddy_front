//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/pages/planning_page.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter/material.dart';

class PlanningPage extends StatefulWidget {
  const PlanningPage({super.key});

  @override
  State<PlanningPage> createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // conserve scroll/état du planificateur

  @override
  void initState() {
    super.initState();
    // TODO: context.read<PlanningBloc>().add(PlanningEvent.loadInitial());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const SafeArea(
      child: Center(
        child: Text('🗓️ Planning – à implémenter'),
      ),
    );
  }
}