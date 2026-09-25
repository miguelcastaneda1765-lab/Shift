import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Campo de texto redondeado con borde teal.
/// Puede mostrar un enlace al lado (ej. "Olvidé mi contraseña").
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
      height: 48,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: AppColors.primary),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.background,
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.primary),
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
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
