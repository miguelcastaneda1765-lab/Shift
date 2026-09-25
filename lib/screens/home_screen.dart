import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_colors.dart';
import '../widgets/home_header.dart';
import '../widgets/FilledPillButton.dart';
import 'home_warmup_screen.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> alumnoData;
  final Map<String, dynamic>? campusData;

  const HomeScreen({super.key, required this.alumnoData, this.campusData});

  @override
  Widget build(BuildContext context) {
    final nombre = alumnoData['Usuario'] ?? 'Alumno';
    final racha = alumnoData['RachaDias'] ?? 0;
    // Ojo: en tu base de datos el campo se llama 'Nombre' (con mayúscula),
    // no 'name' — antes decía 'name' y por eso nunca mostraba nada real.
    final campusNombre = campusData?['Nombre'] ?? 'Campus';
    final metaDiaria = alumnoData['MetaDiaria'] ?? 0;
    // El campo 'Campus' del alumno es una REFERENCIA de Firestore (apunta
    // directo al documento en CampusRanking), así que su .id nos da el ID
    // real sin tener que adivinar ningún nombre de campo extra.
    final String campusId =
        (alumnoData['Campus'] as DocumentReference?)?.id ?? '';
    // TODO PENDIENTE: el ID del propio alumno (ej. "Alumno1") no viene
    // como un campo dentro del documento — Firestore nunca guarda el ID
    // de un documento como un campo de sus propios datos, el ID vive
    // "afuera". Para tenerlo aquí, hay que agregarlo a mano donde se
    // arma alumnoData por primera vez (probablemente en tu pantalla de
    // Login), algo así: {...snapshot.data()!, 'id': snapshot.id}.
    // Mientras tanto, dejo esto en blanco.
    final String alumnoId = alumnoData['id'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado con campus, usuario y racha
              HomeHeader(
                campusName: campusNombre,
                userName: nombre,
                streakDays: racha,
              ),
              const SizedBox(height: 24),

              // 👇 Espacio reservado para tu modelo 3D
              Expanded(
                child: Center(
                  child: Text(
                    'Aquí irá el modelo 3D',
                    style: TextStyle(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Bloque de rutina recomendada: título a la izquierda,
              // pastilla con el tiempo a la derecha, en la misma fila.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rutina recomendada',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.black),
                        SizedBox(width: 4),
                        Text(
                          '5 min',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Botón "Calentemos juntas"
              FilledPillButton(
                label: 'Calentemos juntas',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeWarmupScreen(
                        campusName: campusNombre,
                        userName: nombre,
                        streakDays: racha,
                        alumnoId: alumnoId,
                        campusId: campusId,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Texto motivacional, alineado a la izquierda y en letra
              // pequeña, como en el diseño.
              const Text(
                '¿Lista para entrenar?',
                style: TextStyle(color: AppColors.primary, fontSize: 14),
              ),
              const SizedBox(height: 8),

              // Meta diaria desde la BD, dentro de una caja con borde.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Meta diaria: $metaDiaria min.',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}