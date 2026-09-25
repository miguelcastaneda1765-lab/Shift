import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Barra de navegación inferior usada en Home screens.
class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({super.key, this.currentIndex = 1, this.onTap});

  final int currentIndex;
  final ValueChanged<int>? onTap;

  static const _icons = <IconData>[
    Icons.back_hand_outlined,
    Icons.home_rounded,
    Icons.stars_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_icons.length, (index) {
          final bool isSelected = index == currentIndex;
          return GestureDetector(
            onTap: () => onTap?.call(index),
            behavior: HitTestBehavior.opaque,
            child: Icon(
              _icons[index],
              color: AppColors.lyricwhite,
              size: isSelected ? 30 : 26,
            ),
          );
        }),
      ),
    );
  }
}
