
//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   :presentation/pages/main/landing_page.dart
// Author : Morice
//-------------------------------------------------------------------------


import 'package:flutter/material.dart';
import 'package:texas_buddy/presentation/theme/app_colors.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadNearbyData();
    _loadAdRecommendations();
  }

  Future<void> _loadNearbyData() async {
    // TODO: remplace par un repository réel
    print("📡 Fetching nearby activities and events...");
    // await repo.getNearby(lat, lng);
  }

  Future<void> _loadAdRecommendations() async {
    // TODO: remplace par un repository réel
    print("📡 Fetching ad recommendations...");
    // await repo.getRecommendedAds(fmt: 'native', lat: ..., lng: ...);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Texas Buddy',
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.texasBlue),
          onPressed: () {}, // TODO: ouvrir drawer plus tard
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.texasBlue),
            onPressed: () {}, // TODO: profil user
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.texasBlue,
        currentIndex: _currentIndex,
        onTap: (int index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Carte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Planning',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Communauté',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // Placeholder en attendant d’intégrer la carte
    return const Center(
      child: Text(
        "🗺️ Carte en cours de chargement...",
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
