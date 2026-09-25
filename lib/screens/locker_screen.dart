import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_colors.dart';
import '../theme/deporte_colors.dart';
import '../widgets/bottom_nav_bar.dart';

/// Pantalla de Locker (personalización de avatar): solo color de piel.
/// El color del torso NO se elige aquí — se calcula solo, a partir del
/// deporte asignado al alumno (mismo cálculo que el pill "Entrenando"
/// de Perfil), porque representa la playera de su categoría deportiva.
///
/// Ubicación sugerida: lib/screens/locker_screen.dart
/// Se abre encima de Perfil con Navigator.push (trae flecha de regresar),
/// no es una pestaña más del menú principal.

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

  @override
  Widget build(BuildContext context) {
    final DocumentReference? deporteRef =
        widget.alumnoData['Deporte'] as DocumentReference?;

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
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'No se pudo cargar el locker.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.primary),
                ),
              );
            }

            final String skinKey =
                snapshot.data?.data()?['ColorPiel'] as String? ??
                _defaultSkinKey;
            final Color skinColor =
                _skinTones[skinKey] ?? _skinTones[_defaultSkinKey]!;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 20),
                  // El FutureBuilder de aquí adentro trae el deporte del
                  // alumno UNA vez para saber el color del torso; el
                  // color de piel sí viene del StreamBuilder de arriba
                  // (en vivo), porque ese sí lo cambia esta pantalla.
                  SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: _AvatarPreview(
                      skinColor: skinColor,
                      deporteRef: deporteRef,
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
                    'Color de torso',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Se calcula solo, según tu deporte — no se elige aquí.',
                    style: TextStyle(color: AppColors.primary, fontSize: 12),
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

/// Avatar simple (círculo + rectángulo redondeado) con el color de piel
/// elegido y el color de torso calculado desde el deporte del alumno.
/// Si algún día hay una imagen real del "Mii" en app_config/home, esa
/// se muestra en su lugar automáticamente.
class _AvatarPreview extends StatelessWidget {
  final Color skinColor;
  final DocumentReference? deporteRef;

  const _AvatarPreview({required this.skinColor, required this.deporteRef});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('app_config')
          .doc('home')
          .snapshots(),
      builder: (context, snapshot) {
        final String? imageUrl = snapshot.data?.data()?['imageUrl'] as String?;

        if (!snapshot.hasError && imageUrl != null && imageUrl.isNotEmpty) {
          return Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _buildFallback(),
          );
        }

        return _buildFallback();
      },
    );
  }

  Widget _buildFallback() {
    // Sin ID de deporte todavía (o mientras carga), usa el color
    // principal de la app como respaldo neutro para el torso.
    if (deporteRef == null) {
      return _shapes(torsoColor: AppColors.primary);
    }

    return FutureBuilder<DocumentSnapshot>(
      future: deporteRef!.get(),
      builder: (context, snapshot) {
        final Map<String, dynamic>? data =
            snapshot.data?.data() as Map<String, dynamic>?;
        final Color torsoColor = colorForTipo(data?['Tipo'] as String?);
        return _shapes(torsoColor: torsoColor);
      },
    );
  }

  Widget _shapes({required Color torsoColor}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(shape: BoxShape.circle, color: skinColor),
        ),
        const SizedBox(height: 4),
        Container(
          width: 130,
          height: 140,
          decoration: BoxDecoration(
            color: torsoColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          ),
        ),
      ],
    );
  }
}