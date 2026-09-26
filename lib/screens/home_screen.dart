import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../theme/app_colors.dart';
import '../widgets/home_header.dart';
import '../widgets/FilledPillButton.dart';
import 'home_warmup_screen.dart';

class HomeScreen extends StatelessWidget {
  final String alumnoId;
  final Map<String, dynamic>? campusData;

  const HomeScreen({super.key, required this.alumnoId, this.campusData});

  @override
  Widget build(BuildContext context) {
    final campusNombre = campusData?['Nombre'] ?? 'Campus';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('Alumnos')
              .doc(alumnoId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final alumnoData = snapshot.data!.data() ?? {};
            final nombre = alumnoData['Usuario'] ?? 'Alumno';
            final racha = alumnoData['RachaDias'] ?? 0;
            final metaDiaria = alumnoData['MetaDiaria'] ?? 0;
            final String campusId =
                (alumnoData['Campus'] as DocumentReference?)?.id ?? '';

            final modeloUrl =
                alumnoData['Avatar']?['ModeloUrl'] ??
                alumnoData['Avatar']?['ModeloURL'] ??
                '';

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HomeHeader(
                    campusName: campusNombre,
                    userName: nombre,
                    streakDays: racha,
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: Center(
                      child: modeloUrl.isNotEmpty
                          ? ModelViewer(
                              key: ValueKey(modeloUrl), // 👈 fuerza rebuild
                              src: modeloUrl,
                              alt: "Avatar 3D",
                              autoRotate: true,
                              cameraControls: true,
                              backgroundColor: Colors.transparent,
                            )
                          : Text(
                              'No hay modelo asignado',
                              style: TextStyle(
                                color: AppColors.primary.withOpacity(0.5),
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

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
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.black,
                            ),
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

                  const Text(
                    '¿Lista para entrenar?',
                    style: TextStyle(color: AppColors.primary, fontSize: 14),
                  ),
                  const SizedBox(height: 8),

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
            );
          },
        ),
      ),
    );
  }
}