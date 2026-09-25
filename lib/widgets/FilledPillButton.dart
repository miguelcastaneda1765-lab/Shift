import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Botón grande, relleno, con esquinas totalmente redondeadas ("pastilla").
/// Ubicación sugerida: lib/widgets/filled_pill_button.dart
///
/// Reutilizable en cualquier CTA principal de la app (Login, formularios,
/// confirmaciones), igual que AppBottomNavBar se reutiliza en las pantallas.
class FilledPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? textColor;
  final Color? backgroundColor;

  const FilledPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.textColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor ?? AppColors.background,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}