import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Pill-shaped solid button (e.g. "Ingresar", "Skip", "Break", "Stop").
class FilledPillButton extends StatelessWidget {
  const FilledPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.buttonFilled,
    this.textColor = AppColors.buttonText,
  });

  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: AppSizes.fontButton,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
