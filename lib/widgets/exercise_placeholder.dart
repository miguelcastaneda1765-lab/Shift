import 'package:flutter/material.dart';

/// Espacio reservado (gris claro) para donde eventualmente irá el video
/// o modelo 3D del ejercicio. Mientras tanto, muestra un texto centrado.
/// Ubicación sugerida: lib/widgets/exercise_placeholder.dart
class ExercisePlaceholder extends StatelessWidget {
  final String label;

  const ExercisePlaceholder({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(color: Colors.black87, fontSize: 22),
        ),
      ),
    );
  }
}