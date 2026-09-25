import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Encabezado superior: campus, saludo y días de racha.
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
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '¡Hola, $userName!',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 1.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text(
                '$streakDays días',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'entrenando juntos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primary,
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
