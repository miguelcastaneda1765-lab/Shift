import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tipo de deporte (como se guarda en Firestore, en minúsculas y sin
/// acentos) -> color de categoría en AppColors.
///
/// Ubicación: lib/theme/deporte_colors.dart
/// La usan tanto perfil_screen.dart (pill de "Entrenando") como
/// locker_screen.dart (color del torso del avatar) — un solo lugar para
/// no desincronizarlas.
const Map<String, Color> colorForDeporteTipo = {
  'rendimiento': AppColors.performance, // natación, ciclismo, correr...
  'equipos': AppColors.teams, // fútbol, basketball, volleyball...
  'combate': AppColors.fight, // tae kwon do, box, esgrima
  'fisico': AppColors.physicalFitness, // gimnasio, pilates, yoga
  'expresion': AppColors.expression, // gimnasia artística, baile, ballet...
};

/// Traduce el campo Tipo de un deporte a su color. Si no coincide con
/// ninguna llave conocida (typo, o un tipo nuevo sin color asignado
/// todavía), regresa el color principal de la app en vez de fallar.
Color colorForTipo(String? tipo) {
  final String key = (tipo ?? '').toLowerCase().trim();
  return colorForDeporteTipo[key] ?? AppColors.primary;
}