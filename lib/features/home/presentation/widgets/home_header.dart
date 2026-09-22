import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// Top greeting header shared by every Home screen:
/// campus name, "¡Hola, {name}!" title and the streak-days pill badge.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.campusName,
    required this.userName,
    required this.streakDays,
  });

  final String campusName;
  final String userName;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                campusName,
                style: const TextStyle(
                  color: AppColors.primaryTeal,
                  fontSize: AppSizes.fontBody,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '¡Hola, $userName!',
                style: const TextStyle(
                  color: AppColors.primaryTeal,
                  fontSize: AppSizes.fontTitle,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryTeal, width: 1.2),
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
          child: Column(
            children: [
              Text(
                '$streakDays días',
                style: const TextStyle(
                  color: AppColors.primaryTeal,
                  fontSize: AppSizes.fontBody,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'entrenando juntos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryTeal,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
