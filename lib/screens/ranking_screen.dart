import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';

/// Pantalla de Ranking nacional.
/// Ubicación sugerida: lib/screens/ranking_screen.dart

// ---------------------------------------------------------------------------
// MODELO DE DATOS
// ---------------------------------------------------------------------------
// Representa una fila de la tabla / el podio. Ahora se construye a partir
// de un documento real de Firestore (colección "campus_ranking"), no a mano.

enum RankTrend { up, down, same }

class CampusRanking {
  final int position;
  final String name;
  final int minutes;
  final RankTrend trend;

  const CampusRanking({
    required this.position,
    required this.name,
    required this.minutes,
    required this.trend,
  });

  /// Convierte un documento de Firestore en un CampusRanking.
  ///
  /// [position] no viene guardado en la base de datos: se calcula aparte,
  /// según el lugar que ocupa el documento dentro de la lista ya ordenada
  /// por minutos (ver _RankingScreenState.build). Así nunca se desactualiza,
  /// aunque cambien los minutos de todos los campus.
  ///
  /// [minutesField] decide si leemos 'minutesThisWeek' o 'minutesThisMonth',
  /// según el botón de periodo que el usuario tenga seleccionado.
  factory CampusRanking.fromFirestore({
    required Map<String, dynamic> data,
    required int position,
    required String minutesField,
  }) {
    return CampusRanking(
      position: position,
      name: data['name'] as String? ?? 'Campus',
      minutes: (data[minutesField] as num?)?.toInt() ?? 0,
      // TODO: calcular la tendencia real (subió/bajó/igual) cuando guardemos
      // el historial de minutos de periodos anteriores. Por ahora se deja
      // fija en "same" para no inventar datos que no tenemos.
      trend: RankTrend.same,
    );
  }
}

/// Regresa el color de aro según la posición en el podio (1, 2 o 3).
Color _colorForPosition(int position) {
  switch (position) {
    case 1:
      return AppColors.first;
    case 2:
      return AppColors.second;
    case 3:
      return AppColors.third;
    default:
      return AppColors.lyricwhite.withValues(alpha: 0.5);
  }
}

/// Regresa la etiqueta de texto según la posición en el podio.
String _labelForPosition(int position) {
  switch (position) {
    case 1:
      return 'Líder';
    case 2:
      return 'Top 2';
    case 3:
      return 'Top 3';
    default:
      return 'Top $position';
  }
}

// ---------------------------------------------------------------------------
// PANTALLA PRINCIPAL
// ---------------------------------------------------------------------------
// Es StatefulWidget porque tiene cosas que cambian mientras el usuario
// interactúa: qué botón de periodo está activo, y qué ícono del menú
// está seleccionado.

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  int _selectedPeriod = 0; // 0 = Esta semana, 1 = Este mes
  int _selectedNavIndex = 2; // el ícono de estrella, porque estamos en Ranking

  @override
  Widget build(BuildContext context) {
    // Según el botón de periodo seleccionado, leemos un campo distinto
    // del documento. Estos nombres tienen que coincidir EXACTAMENTE con
    // los campos que crearon en la consola de Firebase.
    final String minutesField =
        _selectedPeriod == 0 ? 'minutesThisWeek' : 'minutesThisMonth';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // StreamBuilder escucha la colección en tiempo real: cada vez que
        // algo cambie en Firestore (alguien registra minutos, por ejemplo),
        // este builder se vuelve a ejecutar automáticamente con los datos
        // nuevos, sin que nadie tenga que recargar la pantalla a mano.
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('campus_ranking')
              .orderBy(minutesField, descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'No se pudo cargar el ranking.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.lyricwhite),
                ),
              );
            }

            // Mientras Firestore responde la primera vez, mostramos un
            // spinner de carga en vez de una pantalla vacía o rota.
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(
                child: Text(
                  'Aún no hay campus registrados.',
                  style: TextStyle(color: AppColors.lyricwhite),
                ),
              );
            }

            // Ya llegaron los documentos ordenados por minutos (de más a
            // menos), así que la posición de cada uno es simplemente su
            // índice en la lista + 1.
            final List<CampusRanking> ranking = List.generate(docs.length, (i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return CampusRanking.fromFirestore(
                data: data,
                position: i + 1,
                minutesField: minutesField,
              );
            });

            // Los primeros 3 van al podio; el resto, a la tabla de abajo.
            final List<CampusRanking> podium = ranking.take(3).toList();
            final List<CampusRanking> rest =
                ranking.length > 3 ? ranking.sublist(3) : const [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ranking',
                    style: TextStyle(
                      color: AppColors.lyricwhite.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Ranking nacional',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPeriodToggle(),
                  const SizedBox(height: 16),
                  _buildAlertBanner(),
                  const SizedBox(height: 24),
                  _buildPodium(podium),
                  const SizedBox(height: 12),
                  _buildPodiumPills(podium),
                  const SizedBox(height: 20),
                  _buildRankingList(rest),
                  const SizedBox(height: 16),
                  _buildImpactCard(),
                  const SizedBox(height: 12),
                  _buildRegisterButton(),
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

  // ---- Botones "Esta semana" / "Este mes" ----
  Widget _buildPeriodToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _periodButton(label: 'Esta semana', index: 0),
        const SizedBox(width: 10),
        _periodButton(label: 'Este mes', index: 1),
      ],
    );
  }

  Widget _periodButton({required String label, required int index}) {
    final bool isSelected = _selectedPeriod == index;
    return GestureDetector(
      // setState reconstruye toda la pantalla, incluyendo el StreamBuilder,
      // que arma una nueva consulta ordenada por el campo correspondiente.
      onTap: () => setState(() => _selectedPeriod = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.background : AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ---- Banner "¿Campus Laguna será ganador?" ----
  Widget _buildAlertBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '¿Campus Laguna será ganador?',
              style: TextStyle(color: AppColors.lyricwhite, fontSize: 13),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.black),
                SizedBox(width: 4),
                Text(
                  '2 días',
                  style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Podio: los 3 círculos con el número de posición ----
  // Recibe la lista ya recortada a los primeros 3 lugares.
  Widget _buildPodium(List<CampusRanking> podium) {
    // Seguridad extra: si por alguna razón hay menos de 3 campus registrados
    // en Firestore, no truena, solo dibuja los que sí existen.
    final Widget? first = podium.isNotEmpty ? _podiumCircleFor(podium[0]) : null;
    final Widget? second = podium.length > 1 ? _podiumCircleFor(podium[1]) : null;
    final Widget? third = podium.length > 2 ? _podiumCircleFor(podium[2]) : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (second != null) second,
        if (first != null) first,
        if (third != null) third,
      ],
    );
  }

  Widget _podiumCircleFor(CampusRanking campus) {
    return _PodiumCircle(
      position: campus.position,
      label: _labelForPosition(campus.position),
      ringColor: _colorForPosition(campus.position),
      size: campus.position == 1 ? 88 : 64,
    );
  }

  // ---- Chips debajo del podio con nombre y minutos ----
  // Usa el MISMO orden visual que _buildPodium (segundo, primero, tercero),
  // para que cada pastilla quede justo debajo de su círculo correspondiente.
  Widget _buildPodiumPills(List<CampusRanking> podium) {
    final CampusRanking? first = podium.isNotEmpty ? podium[0] : null;
    final CampusRanking? second = podium.length > 1 ? podium[1] : null;
    final CampusRanking? third = podium.length > 2 ? podium[2] : null;

    Widget? pillFor(CampusRanking? campus) {
      if (campus == null) return null;
      return _CampusPill(
        name: campus.name,
        minutes: campus.minutes,
        borderColor: _colorForPosition(campus.position),
        highlighted: campus.position == 1,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (pillFor(second) != null) pillFor(second)!,
        if (pillFor(first) != null) pillFor(first)!,
        if (pillFor(third) != null) pillFor(third)!,
      ],
    );
  }

  // ---- Tabla con las posiciones 4 en adelante ----
  Widget _buildRankingList(List<CampusRanking> rest) {
    if (rest.isEmpty) {
      // Con 3 campus o menos en la base de datos, no hay "resto" que
      // mostrar en la tabla — evitamos dibujar un contenedor vacío.
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lyricwhite.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        // Recorremos la lista con un for para poner un Divider (línea)
        // entre cada fila, pero no después de la última.
        children: [
          for (int i = 0; i < rest.length; i++) ...[
            _RankingRow(data: rest[i]),
            if (i != rest.length - 1)
              Divider(color: AppColors.lyricwhite.withValues(alpha: 0.15), height: 1),
          ],
        ],
      ),
    );
  }

  // ---- Tarjeta "Tu impacto hoy" ----
  Widget _buildImpactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lyricwhite.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tu impacto hoy',
                  style: TextStyle(color: AppColors.lyricwhite, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '+20 min. aportados a Campus Laguna',
                  style: TextStyle(color: AppColors.lyricwhite.withValues(alpha: 0.6), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Botón "+ Registrar sesión" ----
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: aquí se conectará con la pantalla de Gimnasio para
          // guardar la sesión real y sumarla al campus del estudiante.
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: const Text(
          '+ Registrar sesión',
          style: TextStyle(color: AppColors.background, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGETS PEQUEÑOS, PRIVADOS DE ESTA PANTALLA
// ---------------------------------------------------------------------------
// El guion bajo (_) al inicio del nombre significa "privado": solo se puede
// usar dentro de este archivo. Como el podio y las filas de la tabla solo
// se usan aquí, no hace falta crearles un archivo aparte.

class _PodiumCircle extends StatelessWidget {
  final int position;
  final String label;
  final Color ringColor;
  final double size;

  const _PodiumCircle({
    required this.position,
    required this.label,
    required this.ringColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLeader = position == 1;
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ringColor, width: 3),
          ),
          child: Text(
            '$position',
            style: TextStyle(
              color: ringColor,
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLeader) ...[
              const Icon(Icons.emoji_events, color: AppColors.first, size: 14),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(color: ringColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

class _CampusPill extends StatelessWidget {
  final String name;
  final int minutes;
  final Color borderColor;
  final bool highlighted;

  const _CampusPill({
    required this.name,
    required this.minutes,
    required this.borderColor,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: highlighted ? 2 : 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(color: borderColor, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            '$minutes min.',
            style: TextStyle(color: AppColors.lyricwhite.withValues(alpha: 0.6), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  final CampusRanking data;

  const _RankingRow({required this.data});

  IconData get _trendIcon {
    switch (data.trend) {
      case RankTrend.up:
        return Icons.arrow_drop_up;
      case RankTrend.down:
        return Icons.arrow_drop_down;
      case RankTrend.same:
        return Icons.drag_handle;
    }
  }

  Color get _trendColor {
    switch (data.trend) {
      case RankTrend.up:
        return AppColors.performance;
      case RankTrend.down:
        return AppColors.fight;
      case RankTrend.same:
        return AppColors.lyricwhite.withValues(alpha: 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            '${data.position}',
            style: const TextStyle(color: AppColors.lyricwhite, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Icon(_trendIcon, color: _trendColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              data.name,
              style: const TextStyle(color: AppColors.lyricwhite, fontSize: 14),
            ),
          ),
          Text(
            '${data.minutes}',
            style: const TextStyle(color: AppColors.lyricwhite, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          Text('min.', style: TextStyle(color: AppColors.lyricwhite.withValues(alpha: 0.6), fontSize: 12)),
        ],
      ),
    );
  }
}