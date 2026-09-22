import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Pill-shaped button with a teal outline and transparent background.
/// Used for the "Timer" style buttons on the Home screens.
class OutlinePillButton extends StatelessWidget {
  const OutlinePillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.textColor = AppColors.primaryTeal,
    this.borderColor = AppColors.primaryTeal,
  });

  final String label;
  final VoidCallback onPressed;
  final Color textColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: AppSizes.fontButton,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
