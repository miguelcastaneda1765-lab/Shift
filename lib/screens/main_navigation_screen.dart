import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import 'rutinas_screen.dart';
import 'home_screen.dart';
import 'ranking_screen.dart';
import 'perfil_screen.dart';

/// Pantalla raíz de navegación.
/// Ubicación sugerida: lib/screens/main_navigation_screen.dart
///
/// Es la ÚNICA pantalla que tiene Scaffold y AppBottomNavBar. Las otras 4
/// (RoutinesScreen, HomeScreen, RankingScreen, ProfileScreen) son solo
/// "contenido" — este widget decide cuál se ve, según el ícono tocado.
///
/// Orden del menú (mano, casa, estrella, persona) = índices 0, 1, 2, 3:
///   0 -> Tutoriales   1 -> Home   2 -> Ranking   3 -> Perfil
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 1; // arranca en Home

  // Las 4 pantallas, en el mismo orden que los íconos del menú.
  // Son "const" y viven aquí una sola vez: IndexedStack las mantiene
  // todas construidas (no las destruye al cambiar de tab), así que si
  // alguien deja un timer corriendo en Tutoriales y cambia a Ranking,
  // el timer sigue corriendo al regresar.
  static const List<Widget> _screens = [
    RoutinesScreen(), // 0 - mano
    HomeScreen(), // 1 - casa
    RankingScreen(), // 2 - estrella
    ProfileScreen(), // 3 - persona
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
