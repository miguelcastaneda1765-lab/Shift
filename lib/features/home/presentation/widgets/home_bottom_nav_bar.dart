import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// Teal pill-shaped bottom navigation bar used across Home screens.
/// Icons use the closest Material equivalents as placeholders:
///  - back_hand  -> "pause/hand" action
///  - home       -> home tab
///  - star (outlined circle) -> favorites/highlights tab
///  - person     -> profile tab
class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({
    super.key,
    this.currentIndex = 1,
    this.onTap,
  });

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
      height: AppSizes.bottomNavHeight,
      decoration: BoxDecoration(
        color: AppColors.primaryTeal,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
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
              color: AppColors.buttonText,
              size: isSelected ? 30 : 26,
            ),
          );
        }),
      ),
    );
  }
}
