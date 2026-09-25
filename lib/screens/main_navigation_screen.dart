import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import 'rutinas_screen.dart';
import 'home_screen.dart';
import 'ranking_screen.dart';
import 'perfil_screen.dart';

/// Pantalla raíz de navegación.
/// Recibe los datos del alumno y campus desde el login.
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
  int _selectedIndex = 1; // arranca en Home

  void _goToTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    // Las pantallas reciben los datos del alumno y campus
    final List<Widget> screens = [
      RoutinesScreen(
        alumnoData: widget.alumnoData,
        campusData: widget.campusData,
      ), // 0 - mano
      HomeScreen(
        alumnoData: widget.alumnoData,
        campusData: widget.campusData,
      ), // 1 - casa
      RankingScreen(
        alumnoData: widget.alumnoData,
        campusData: widget.campusData,
        // Al tocar "+ Registrar sesión" en Ranking, esto cambia la pestaña
        // seleccionada aquí en la raíz, y el IndexedStack de abajo muestra
        // Home en vez de Ranking.
        onGoHome: () => _goToTab(1),
      ), // 2 - estrella
      ProfileScreen(
        alumnoData: widget.alumnoData,
        campusData: widget.campusData,
      ), // 3 - persona
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