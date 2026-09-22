import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// Gray placeholder box standing in for the exercise photo/gif.
class ExercisePlaceholder extends StatelessWidget {
  const ExercisePlaceholder({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.placeholderGray,
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.placeholderTextDark,
            fontSize: AppSizes.fontTitle,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}