import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Botón tipo "pastilla" con solo borde (sin relleno) — el complemento de
/// FilledPillButton para acciones secundarias.
/// Ubicación sugerida: lib/widgets/outline_pill_button.dart
class OutlinePillButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const OutlinePillButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}