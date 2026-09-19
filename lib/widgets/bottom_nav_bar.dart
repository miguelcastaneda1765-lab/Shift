import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
 
/// Barra de navegación inferior compartida por toda la app.

/// ```dart
/// Scaffold(
///   bottomNavigationBar: AppBottomNavBar(
///     currentIndex: 1, // el ícono que debe verse "seleccionado" en ESA pantalla
///     onTap: (index) {
///       // aquí cada quien decide a dónde navegar según el índice
///       // 0 = mano, 1 = home, 2 = ranking, 3 = perfil
///     },
///   ),
/// )
/// ```

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
 
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });
 
  static const List<IconData> _icons = [
    Icons.front_hand_outlined,
    Icons.home_outlined,
    Icons.star_outline,
    Icons.person_outline,
  ];
 
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        // List.generate crea un widget por cada ícono en _icons,
        // así no repetimos el mismo código 4 veces.
        children: List.generate(_icons.length, (index) {
          final bool isSelected = index == currentIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: AppColors.lyricwhite, width: 2)
                    : null,
              ),
              child: Icon(
                _icons[index],
                color: AppColors.lyricwhite,
                size: 24,
              ),
            ),
          );
        }),
      ),
    );
  }
}