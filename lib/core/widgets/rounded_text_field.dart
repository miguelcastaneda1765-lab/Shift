import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Rounded, teal-outlined text field used on the login screen.
/// Optionally shows a trailing label/link (e.g. "Olvidé mi contraseña").
class RoundedTextField extends StatelessWidget {
  const RoundedTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.trailingLabel,
    this.onTrailingTap,
    this.controller,
  });

  final String hintText;
  final bool obscureText;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.inputHeight,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.inputBackground,
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textMuted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          suffixIcon: trailingLabel == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    widthFactor: 1,
                    child: GestureDetector(
                      onTap: onTrailingTap,
                      child: Text(
                        trailingLabel!,
                        style: const TextStyle(
                          color: AppColors.primaryTeal,
                          fontSize: AppSizes.fontSmall,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusInput),
            borderSide: const BorderSide(color: AppColors.borderTeal, width: 1.4),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusInput),
            borderSide: const BorderSide(color: AppColors.borderTeal, width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusInput),
            borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
          ),
        ),
      ),
    );
  }
}
