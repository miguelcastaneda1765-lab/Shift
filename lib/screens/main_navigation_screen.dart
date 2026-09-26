import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import 'rutinas_screen.dart';
import 'home_screen.dart';
import 'ranking_screen.dart';
import 'perfil_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final Map<String, dynamic> alumnoData;
  final Map<String, dynamic>? campusData;

  const MainNavigationScreen({
    super.key,
    required this.alumnoData,
    this.campusData,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0; // ✅ Home arranca en índice 0

  void _goToTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final String alumnoId = widget.alumnoData['id'] as String? ?? '';

    final List<Widget> screens = [
      HomeScreen(alumnoId: alumnoId, campusData: widget.campusData), // 0 - Home
      RoutinesScreen(
        alumnoData: widget.alumnoData,
        campusData: widget.campusData,
      ), // 1 - Rutinas/Tutoriales
      RankingScreen(
        alumnoData: widget.alumnoData,
        campusData: widget.campusData,
        onGoHome: () => _goToTab(0),
      ), // 2 - Ranking
      ProfileScreen(
        alumnoData: widget.alumnoData,
        campusData: widget.campusData,
      ), // 3 - Perfil
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _goToTab,
      ),
    );
  }
}
