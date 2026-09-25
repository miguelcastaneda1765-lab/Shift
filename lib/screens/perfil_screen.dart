import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_colors.dart';
import '../theme/deporte_colors.dart';
import 'locker_screen.dart';

/// Contenido de la pantalla de Perfil.
/// Ubicación: lib/screens/perfil_screen.dart
///
/// Ahora recibe alumnoData y campusData ya cargados desde
/// MainNavigationScreen (mismo patrón que HomeScreen), en vez de volver a
/// leerlos de Firestore aquí mismo.
///
/// OJO: como los datos llegan como prop (un "snapshot" fijo en el momento
/// en que se armó MainNavigationScreen), esta pantalla YA NO se actualiza
/// sola si algo cambia en Firestore mientras el alumno la tiene abierta
/// (a diferencia de antes, que sí, por el StreamBuilder). Si eso importa
/// —por ejemplo, que la racha se actualice sin salir y volver a entrar—
/// hay que resolverlo en el nivel de MainNavigationScreen, no aquí.

const Color _logoutRed = Color(0xFFE53935);

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> alumnoData;
  final Map<String, dynamic>? campusData;

  const ProfileScreen({super.key, required this.alumnoData, this.campusData});

  @override
  Widget build(BuildContext context) {
    final String name =
        alumnoData['Nombre'] as String? ??
        alumnoData['Usuario'] as String? ??
        'Alumno';
    final String campusNombre = campusData?['name'] as String? ?? '';
    final String campusName = campusNombre.isEmpty
        ? ''
        : 'Campus $campusNombre';
    final int days =
        (alumnoData['Racha_Dias'] as num?)?.toInt() ??
        (alumnoData['RachaDias'] as num?)?.toInt() ??
        0;
    final int minutosTotales =
        (alumnoData['minutosTotales'] as num?)?.toInt() ?? 0;
    final int promedioSemanal =
        (alumnoData['promedioSemanal'] as num?)?.toInt() ?? 0;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 8),
              const SizedBox(
                height: 150,
                width: double.infinity,
                child: _ProfileImageSlot(),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  campusName,
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTrainingRow(
                days: days,
                deporteRef: alumnoData['Deporte'] as DocumentReference?,
              ),
              const SizedBox(height: 20),
              _buildLockerButton(context),
              const SizedBox(height: 24),
              _buildSemesterStats(
                minutosTotales: minutosTotales,
                promedioSemanal: promedioSemanal,
              ),
              const SizedBox(height: 24),
              _buildAchievements(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Perfil',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        OutlinedButton(
          onPressed: () {
            // TODO: cerrar sesión (Firebase Auth) y regresar a Login.
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: _logoutRed,
            side: const BorderSide(color: _logoutRed),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Cerrar\nsesión',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingRow({
    required int days,
    required DocumentReference? deporteRef,
  }) {
    final Color line = AppColors.primary.withValues(alpha: 0.6);

    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: line)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    const Text(
                      'Entrenando',
                      style: TextStyle(color: AppColors.primary, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    _DeportePill(deporteRef: deporteRef),
                  ],
                ),
              ),
            ),
            VerticalDivider(color: line, width: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    const Text(
                      'Días',
                      style: TextStyle(color: AppColors.primary, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$days',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockerButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LockerScreen(alumnoData: alumnoData),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checkroom, color: AppColors.background),
            SizedBox(width: 12),
            Text(
              'Tu locker',
              style: TextStyle(
                color: AppColors.background,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 12),
            Icon(Icons.chevron_right, color: AppColors.background),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterStats({
    required int minutosTotales,
    required int promedioSemanal,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Este semestre'),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Movimiento total',
                  value: _formatThousands(minutosTotales),
                  caption: 'minutos acumulados',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Promedio semanal',
                  value: _formatThousands(promedioSemanal),
                  unit: 'min.',
                  icon: Icons.trending_up,
                  caption: 'objetivo cumplido',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Tus logros'),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _AchievementTile.unlocked(
                title: '¡Espíritu Halcón!',
                subtitle: 'Has entrenado por 10 días',
              ),
            ),
            SizedBox(width: 12),
            Expanded(child: _AchievementTile.locked()),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _AchievementTile.locked()),
            SizedBox(width: 12),
            Expanded(child: _AchievementTile.locked()),
          ],
        ),
      ],
    );
  }
}

String _formatThousands(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String caption;
  final String? unit;
  final IconData? icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.caption,
    this.unit,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final Widget valueText = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        value,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 44,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (icon == null)
            valueText
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(child: valueText),
                const Spacer(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(icon, size: 40, color: AppColors.primary),
                    if (unit != null)
                      Text(
                        unit!,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 8),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.primary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const _AchievementTile.locked() : title = null, subtitle = null;

  const _AchievementTile.unlocked({
    required this.title,
    required this.subtitle,
  });

  bool get _isLocked => title == null;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(24),
      ),
      child: _isLocked
          ? const Center(
              child: Icon(Icons.lock, color: AppColors.primary, size: 22),
            )
          : Row(
              children: [
                const Icon(Icons.stars, color: AppColors.primary, size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.primary.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Igual que en Home: lee app_config/home, campo 'imageUrl'. Esta sí sigue
/// con su propio StreamBuilder porque es una imagen compartida por todos
/// los alumnos, no un dato personal que venga en alumnoData.
class _ProfileImageSlot extends StatelessWidget {
  const _ProfileImageSlot();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('app_config')
          .doc('home')
          .snapshots(),
      builder: (context, snapshot) {
        final String? imageUrl = snapshot.data?.data()?['imageUrl'] as String?;

        if (snapshot.hasError || imageUrl == null || imageUrl.isEmpty) {
          return const SizedBox.expand();
        }

        return SizedBox.expand(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// PILL DE DEPORTE, CONECTADO A LA COLECCIÓN "Deportes"
// ---------------------------------------------------------------------------
// El alumno guarda una REFERENCIA (DocumentReference) al deporte que
// practica, igual que con Campus. Este widget sigue esa referencia, trae
// el documento real de "Deportes", y pinta el pill con su Nombre.
//
// El color viene de colorForTipo(), en theme/deporte_colors.dart — el
// mismo cálculo que usa Locker para el color del torso, así nunca
// quedan desincronizados.

class _DeportePill extends StatelessWidget {
  final DocumentReference? deporteRef;

  const _DeportePill({required this.deporteRef});

  Widget _pill({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Si el alumno todavía no tiene ningún deporte asignado en la base
    // de datos, mostramos un pill neutro en vez de tronar.
    if (deporteRef == null) {
      return _pill(label: '—', color: AppColors.primary);
    }

    return FutureBuilder<DocumentSnapshot>(
      future: deporteRef!.get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _pill(
            label: '...',
            color: AppColors.primary.withValues(alpha: 0.5),
          );
        }

        final Map<String, dynamic>? data =
            snapshot.data?.data() as Map<String, dynamic>?;
        if (data == null) {
          return _pill(label: '—', color: AppColors.primary);
        }

        final String nombre = data['Nombre'] as String? ?? '—';
        final String? tipo = data['Tipo'] as String?;
        final Color color = colorForTipo(tipo);

        return _pill(label: nombre, color: color);
      },
    );
  }
}