//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/community/presentation/pages/community_page.dart
// Author : Morice
//---------------------------------------------------------------------------


import 'package:flutter/material.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // conserve scroll/état des listes


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const SafeArea(
      child: Center(
        child: Text('👥 Community – à implémenter'),
      ),
    );
  }
}
