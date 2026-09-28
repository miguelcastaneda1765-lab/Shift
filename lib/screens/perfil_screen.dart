import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../theme/app_colors.dart';
import '../theme/deporte_colors.dart';
import 'locker_screen.dart';
import 'login_screen.dart';

const Color _logoutRed = Color(0xFFE53935);

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> alumnoData;
  final Map<String, dynamic>? campusData;

  const ProfileScreen({super.key, required this.alumnoData, this.campusData});

  int _readInt(Map<String, dynamic> data, List<String> keys) {
    for (final k in keys) {
      final v = data[k];
      if (v is num) return v.toInt();
      if (v is String) {
        final parsed = int.tryParse(v);
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final String alumnoId = alumnoData['id'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('Alumnos')
              .doc(alumnoId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al cargar perfil',
                  style: TextStyle(color: AppColors.primary),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() ?? <String, dynamic>{};

            final String nombre = data['Nombre'] ?? data['Usuario'] ?? 'Alumno';
            final String campusNombre = campusData?['Nombre'] ?? '';

            // 🔧 Corrección: leer Cabello y decidir modelo
            final avatar = data['Avatar'] ?? {};
            final String cabello = avatar['Cabello'] ?? 'corto';

            String modeloUrl = '';
            if (cabello == 'corto') {
              modeloUrl = avatar['ModeloUrlCorto'] ?? '';
            } else if (cabello == 'largo') {
              modeloUrl = avatar['ModeloUrlLargo'] ?? '';
            }

            final int minutosTotales = _readInt(data, [
              'MinutosTotales',
              'minutosTotales',
              'Minutos_totales',
            ]);
            final int promedioSemanalFromDb = _readInt(data, [
              'PromedioSemanal',
              'promedioSemanal',
              'promedio_semanal',
            ]);

            int promedioSemanalComputed = 0;
            if (promedioSemanalFromDb > 0) {
              promedioSemanalComputed = promedioSemanalFromDb;
            } else {
              final createdTs = data['createdAt'] as Timestamp?;
              if (createdTs != null && minutosTotales > 0) {
                final created = createdTs.toDate();
                final weeks = (DateTime.now().difference(created).inDays / 7)
                    .clamp(1, 1000)
                    .ceil();
                promedioSemanalComputed = (minutosTotales / weeks).round();
              } else if (minutosTotales > 0) {
                promedioSemanalComputed = minutosTotales;
              } else {
                promedioSemanalComputed = 0;
              }
            }

            final DocumentReference? deporteRef =
                data['Deporte'] as DocumentReference?;
            final int rachaDias = (data['RachaDias'] as num?)?.toInt() ?? 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: modeloUrl.isNotEmpty
                        ? ModelViewer(
                            key: ValueKey(modeloUrl),
                            src: modeloUrl,
                            alt: 'Avatar 3D',
                            autoRotate: true,
                            cameraControls: true,
                            backgroundColor: Colors.transparent,
                          )
                        : const Center(
                            child: Icon(
                              Icons.person,
                              size: 96,
                              color: AppColors.primary,
                            ),
                          ),
                  ),

                  const SizedBox(height: 12),

                  Center(
                    child: Text(
                      nombre,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      campusNombre.isEmpty ? '' : 'Campus $campusNombre',
                      style: TextStyle(
                        color: AppColors.primary.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildTrainingRow(
                    rachaDias: rachaDias,
                    deporteRef: deporteRef,
                    alumnoId: alumnoId,
                  ),

                  const SizedBox(height: 20),
                  _buildLockerButton(context),
                  const SizedBox(height: 20),

                  _buildSemesterStats(
                    minutosTotales: minutosTotales,
                    promedioSemanal: promedioSemanalComputed,
                    promedioFromDb: promedioSemanalFromDb > 0
                        ? promedioSemanalFromDb
                        : null,
                  ),

                  const SizedBox(height: 24),
                  _buildAchievements(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          onPressed: () async {
            try {
              await FirebaseAuth.instance.signOut();

              // Si usas rutas nombradas y tienes '/login' registrada en MaterialApp:
              try {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
                return;
              } catch (_) {
                // Si la ruta nombrada no existe, hacemos fallback abajo.
              }

              // Fallback: abrir LoginScreen por widget (ajusta el import y la clase)
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            } catch (e, st) {
              // Log para depuración
              debugPrint('Error al cerrar sesión: $e\n$st');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No se pudo cerrar sesión. Intenta de nuevo.'),
                ),
              );
            }
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
    required int rachaDias,
    required DocumentReference? deporteRef,
    required String alumnoId,
  }) {
    final Color line = AppColors.primary.withOpacity(0.6);

    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: line)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Columna Deporte (ahora usamos DeporteSelector estilo pill)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    const Text(
                      'Entrenando',
                      style: TextStyle(color: AppColors.primary, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    DeporteSelector(
                      alumnoId: alumnoId,
                      selectedDeporteRef: deporteRef,
                    ),
                  ],
                ),
              ),
            ),

            // Divider vertical
            VerticalDivider(color: line, width: 1),

            // Columna Racha
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    const Text(
                      'Días',
                      style: TextStyle(color: AppColors.primary, fontSize: 14),
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
                        '$rachaDias días',
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
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (c) => LockerScreen(alumnoData: alumnoData),
          ),
        ),
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
    int? promedioFromDb,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Este semestre'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Movimiento total',
                value: minutosTotales > 0
                    ? _formatThousands(minutosTotales)
                    : '—',
                caption: 'minutos acumulados',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Promedio semanal',
                value: promedioSemanal > 0
                    ? _formatThousands(promedioSemanal)
                    : '—',
                unit: 'min.',
                icon: Icons.trending_up,
                caption: promedioFromDb != null
                    ? 'promedio guardado'
                    : 'promedio calculado',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
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

// -------------------- AUXILIARES --------------------

String _formatThousands(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppColors.primary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  );
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Widget valueText = Text(
      value,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 44,
        fontWeight: FontWeight.bold,
      ),
    );

    return Container(
      height: 120,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
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
          Expanded(
            child: Center(
              child: FittedBox(fit: BoxFit.scaleDown, child: valueText),
            ),
          ),
          const SizedBox(height: 8),
          if (icon != null || unit != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Icon(icon, size: 20, color: AppColors.primary),
                if (icon != null && unit != null) const SizedBox(width: 6),
                if (unit != null)
                  Text(
                    unit!,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
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
  const _AchievementTile.locked({super.key}) : title = null, subtitle = null;
  const _AchievementTile.unlocked({
    required this.title,
    required this.subtitle,
    super.key,
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
                          color: AppColors.primary.withOpacity(0.7),
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

/// Slot de imagen (lee app_config/home -> imageUrl)
class _ProfileImageSlot extends StatelessWidget {
  const _ProfileImageSlot({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('app_config')
          .doc('home')
          .snapshots(),
      builder: (context, snapshot) {
        final String? imageUrl = snapshot.data?.data()?['imageUrl'] as String?;
        if (snapshot.hasError || imageUrl == null || imageUrl.isEmpty)
          return const SizedBox.expand();
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

/// Selector visual de deporte: pill que abre modal con lista de deportes.
/// Al seleccionar guarda la referencia en Alumnos/{id}.Deporte
class DeporteSelector extends StatelessWidget {
  final String alumnoId;
  final DocumentReference? selectedDeporteRef;

  const DeporteSelector({
    super.key,
    required this.alumnoId,
    required this.selectedDeporteRef,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('Deportes')
          .orderBy('Nombre')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Text('Error', style: TextStyle(color: AppColors.primary));
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 40,
            width: 120,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final deportes = snapshot.data!.docs;
        final String? selectedId = selectedDeporteRef?.id;
        QueryDocumentSnapshot<Map<String, dynamic>>? selectedDoc;
        if (selectedId != null) {
          try {
            selectedDoc = deportes.firstWhere((d) => d.id == selectedId);
          } catch (_) {
            selectedDoc = null;
          }
        }

        final String label = selectedDoc != null
            ? (selectedDoc.data()['Nombre'] ?? '—').toString()
            : '—';
        final String? tipo = selectedDoc != null
            ? (selectedDoc.data()['Tipo'] as String?)
            : null;
        final Color bgColor = tipo != null
            ? colorForTipo(tipo)
            : AppColors.primary;

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openDeportesSheet(context, deportes),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // pequeño indicador de color a la izquierda (como icono)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDeportesSheet(
    BuildContext context,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> deportes,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selecciona un deporte',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: deportes.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Colors.transparent),
                  itemBuilder: (context, index) {
                    final doc = deportes[index];
                    final data = doc.data();
                    final nombre = (data['Nombre'] ?? 'Sin nombre').toString();
                    final tipo = data['Tipo'] as String?;
                    final color = colorForTipo(tipo);

                    return ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      title: Text(
                        nombre,
                        style: const TextStyle(color: AppColors.primary),
                      ),
                      subtitle: tipo != null
                          ? Text(
                              tipo,
                              style: TextStyle(
                                color: AppColors.primary.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            )
                          : null,
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .collection('Alumnos')
                            .doc(alumnoId)
                            .update({
                              'Deporte': FirebaseFirestore.instance
                                  .collection('Deportes')
                                  .doc(doc.id),
                            });
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
