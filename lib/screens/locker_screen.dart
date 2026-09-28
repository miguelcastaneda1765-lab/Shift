import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../theme/app_colors.dart';
import '../theme/deporte_colors.dart';
import '../widgets/bottom_nav_bar.dart';

const Map<String, Color> _skinTones = {
  'clara': Color(0xFFF7D7C4),
  'media_clara': Color(0xFFE8B894),
  'media': Color(0xFFC68642),
  'media_oscura': Color(0xFF8D5524),
  'oscura': Color(0xFF5C3A21),
};

const String _defaultSkinKey = 'media';

class LockerScreen extends StatefulWidget {
  final Map<String, dynamic> alumnoData;

  const LockerScreen({super.key, required this.alumnoData});

  @override
  State<LockerScreen> createState() => _LockerScreenState();
}

class _LockerScreenState extends State<LockerScreen> {
  String get _studentDocId => widget.alumnoData['id'] as String? ?? '';

  Future<void> _updateSkinColor(String key) {
    if (_studentDocId.isEmpty) return Future.value();
    return FirebaseFirestore.instance
        .collection('Alumnos')
        .doc(_studentDocId)
        .update({'ColorPiel': key});
  }

  Future<void> _updateHairModel(String hairKey) {
    if (_studentDocId.isEmpty) return Future.value();
    // Guardamos la elección de cabello en Firestore
    return FirebaseFirestore.instance
        .collection('Alumnos')
        .doc(_studentDocId)
        .update({'Avatar.Cabello': hairKey});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _studentDocId.isEmpty
              ? const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty()
              : FirebaseFirestore.instance
                    .collection('Alumnos')
                    .doc(_studentDocId)
                    .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() ?? {};
            final String skinKey =
                data['ColorPiel'] as String? ?? _defaultSkinKey;
            final Color skinColor =
                _skinTones[skinKey] ?? _skinTones[_defaultSkinKey]!;

            final avatar = data['Avatar'] ?? {};
            final String cabello = avatar['Cabello'] ?? 'corto';

            // Seleccionamos el modelo según el campo Cabello
            String modeloUrl = '';
            if (cabello == 'corto') {
              modeloUrl = avatar['ModeloUrlCorto'] ?? '';
            } else if (cabello == 'largo') {
              modeloUrl = avatar['ModeloUrlLargo'] ?? '';
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 20),

                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: modeloUrl.isNotEmpty
                        ? ModelViewer(
                            key: ValueKey(
                              modeloUrl,
                            ), // 👈 fuerza recarga al cambiar
                            src: modeloUrl,
                            alt: "Avatar 3D",
                            autoRotate: true,
                            cameraControls: true,
                            backgroundColor: Colors.transparent,
                          )
                        : const Text(
                            'No hay modelo asignado',
                            style: TextStyle(color: AppColors.primary),
                          ),
                  ),

                  const SizedBox(height: 28),
                  const Text(
                    'Color de piel',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSkinSwatches(skinKey),

                  const SizedBox(height: 24),
                  const Text(
                    'Cabello',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: ['corto', 'largo'].map((hairKey) {
                      final bool isSelected = cabello == hairKey;
                      return GestureDetector(
                        onTap: () => _updateHairModel(hairKey),
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.2)
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.face,
                                color: AppColors.primary,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                hairKey.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3,
        onTap: (index) => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.checkroom, color: AppColors.primary, size: 20),
        const SizedBox(width: 6),
        const Text(
          'Tu locker',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSkinSwatches(String selectedKey) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: _skinTones.entries.map((entry) {
        final bool isSelected = entry.key == selectedKey;
        return GestureDetector(
          onTap: () => _updateSkinColor(entry.key),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: entry.value,
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }
}