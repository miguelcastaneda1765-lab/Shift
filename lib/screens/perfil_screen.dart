import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';

/// Pantalla de Perfil.
/// Ubicación: lib/screens/profile_screen.dart

const Color _logoutRed = Color(0xFFE53935);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // En el diseño el ícono de la persona es el cuarto de la barra
  // (mano, casa, estrella, persona), así que Perfil = 3.
  int _selectedNavIndex = 3;

  // Mismo alumno que en el Home.
  // TODO: cuando haya inicio de sesión, cambiarlo por el uid del usuario.
  static const String _studentDocId = 'IdAlumno';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('Alumnos')
              .doc(_studentDocId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'No se pudieron cargar tus datos.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.lyricwhite),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            // Los nombres de los campos tienen que coincidir EXACTAMENTE
            // con los de la consola de Firebase (incluyendo mayúsculas).
            final Map<String, dynamic> data = snapshot.data!.data() ?? {};
            final String name = data['Nombre'] as String? ?? 'Alumno';
            final String campus = data['Campus'] as String? ?? '';
            final String campusName = campus.isEmpty ? '' : 'Campus $campus';
            final int days = (data['Racha_Dias'] as num?)?.toInt() ?? 0;

            // Estadísticas: ya vienen guardadas en el documento del alumno.
            final int minutosTotales = (data['minutosTotales'] as num?)?.toInt() ?? 0;
            final int promedioSemanal = (data['promedioSemanal'] as num?)?.toInt() ?? 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 8),

                  // Espacio para la imagen de la app (hoy el "Mii" del
                  // diseño). Queda vacío hasta que haya una URL en Firestore.
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
                        color: AppColors.lyricwhite.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTrainingRow(days: days),
                  const SizedBox(height: 20),
                  _buildLockerButton(),
                  const SizedBox(height: 24),
                  _buildSemesterStats(
                    minutosTotales: minutosTotales,
                    promedioSemanal: promedioSemanal,
                  ),
                  const SizedBox(height: 24),
                  _buildAchievements(),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) => setState(() => _selectedNavIndex = index),
      ),
    );
  }

  // ---- Barra superior: "Perfil" + botón "Cerrar sesión" ----
  Widget _buildTopBar() {
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
            // TODO: cerrar sesión (cuando se agregue Firebase Auth).
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

  // ---- Fila "Entrenando" (deporte) | "Días" ----
  Widget _buildTrainingRow({required int days}) {
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
                      style: TextStyle(
                        color: AppColors.lyricwhite,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _SportPill(studentId: _studentDocId),
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
                      style: TextStyle(
                        color: AppColors.lyricwhite,
                        fontSize: 12,
                      ),
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

  // ---- Botón grande "Tu locker >" ----
  Widget _buildLockerButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: abrir la pantalla del locker.
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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

  // ---- "Este semestre": movimiento total y promedio semanal ----
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
                  // TODO: comparar contra la meta semanal para decidir si
                  // el texto es "objetivo cumplido" o algo distinto.
                  caption: 'objetivo cumplido',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---- "Tus logros" (estáticos por ahora) ----
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

// ---------------------------------------------------------------------------
// FUNCIONES AUXILIARES
// ---------------------------------------------------------------------------

/// Da formato con comas de miles: 8420 -> "8,420".
String _formatThousands(int value) {
  return value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
      );
}

/// Quita mayúsculas y acentos para comparar nombres de deportes:
/// "Natación" y "natacion" cuentan como el mismo deporte.
String _normalize(String text) {
  return text
      .trim()
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u');
}

/// Deporte -> color de su categoría (los colores viven en AppColors).
/// Las llaves van sin acentos y en minúsculas.
const Map<String, Color> _sportColors = {
  // Tiempo o rendimiento (verde)
  'natacion': AppColors.performance,
  'ciclismo': AppColors.performance,
  'correr': AppColors.performance,
  'atletismo': AppColors.performance,
  'escalada': AppColors.performance,
  'patinaje de velocidad': AppColors.performance,

  // Confrontación de equipos (naranja)
  'futbol': AppColors.teams,
  'basketball': AppColors.teams,
  'volleyball': AppColors.teams,
  'tocho': AppColors.teams,
  'futbol americano': AppColors.teams,
  'tenis': AppColors.teams,
  'beisbol': AppColors.teams,
  'handball': AppColors.teams,

  // Combate (rojo)
  'tae kwon do': AppColors.fight,
  'box': AppColors.fight,
  'esgrima': AppColors.fight,

  // Acondicionamiento físico (azul)
  'gimnasio': AppColors.physicalFitness,
  'pilates': AppColors.physicalFitness,
  'yoga': AppColors.physicalFitness,

  // Expresión o técnico-combinatorios (amarillo)
  'gimnasia artistica': AppColors.expression,
  'baile': AppColors.expression,
  'ballet': AppColors.expression,
  'patinaje artistico': AppColors.expression,
};

/// Color del botón "Entrenando" según el deporte. Si el deporte no está
/// en la lista (o no hay), usa el color principal.
Color _colorForSport(String? sport) {
  if (sport == null) return AppColors.primary;
  return _sportColors[_normalize(sport)] ?? AppColors.primary;
}

// ---------------------------------------------------------------------------
// WIDGETS PEQUEÑOS, PRIVADOS DE ESTA PANTALLA
// ---------------------------------------------------------------------------

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

/// Botón "Gimnasio": lee el deporte de Entrenamientos/{studentId}
/// (campo 'Deporte') y cambia de color según el deporte.
class _SportPill extends StatelessWidget {
  final String studentId;

  const _SportPill({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('Entrenamientos')
          .doc(studentId)
          .snapshots(),
      builder: (context, snapshot) {
        final String? sport = snapshot.data?.data()?['Deporte'] as String?;
        final String label = (sport == null || sport.isEmpty) ? '—' : sport;
        final Color sportColor = _colorForSport(sport);
        // El texto blanco no se lee sobre el amarillo, ahí va oscuro.
        final Color textColor =
            sportColor == AppColors.expression ? AppColors.background : Colors.white;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: sportColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}

/// Tarjeta de estadística con borde redondeado.
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

/// Logro: desbloqueado (con estrella, título y subtítulo) o bloqueado
/// (solo un candado).
class _AchievementTile extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const _AchievementTile.locked()
      : title = null,
        subtitle = null;

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
                          color: AppColors.lyricwhite,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.lyricwhite.withValues(alpha: 0.7),
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

// ---------------------------------------------------------------------------
// ESPACIO DE IMAGEN CONECTADO A FIRESTORE
// ---------------------------------------------------------------------------
// Igual que en el Home: lee app_config/home, campo 'imageUrl'. Queda vacío
// si no hay documento, campo o URL válida. Estos nombres son provisionales.

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
