import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
 
/// Pantalla de Ranking nacional. 
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
 
  // Datos de ejemplo. Después de la posición 3 (que se muestra en el podio).
  final List<CampusRanking> _restOfRanking = const [
    CampusRanking(position: 4, name: 'Campus Mérida', minutes: 3120, trend: RankTrend.up),
    CampusRanking(position: 5, name: 'Campus Querétaro', minutes: 2000, trend: RankTrend.same),
    CampusRanking(position: 6, name: 'Campus Puebla', minutes: 1500, trend: RankTrend.down),
    CampusRanking(position: 7, name: 'Campus Saltillo', minutes: 899, trend: RankTrend.down),
  ];
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // SingleChildScrollView permite hacer scroll si el contenido
        // no cabe completo en pantallas pequeñas.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ranking',
                style: TextStyle(color: AppColors.lyricwhite.withValues(alpha: 0.6), fontSize: 13),
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
              _buildPodium(),
              const SizedBox(height: 12),
              _buildPodiumPills(),
              const SizedBox(height: 20),
              _buildRankingList(),
              const SizedBox(height: 16),
              _buildImpactCard(),
              const SizedBox(height: 12),
              _buildRegisterButton(),
            ],
          ),
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
      // setState le dice a Flutter "algo cambió, vuelve a dibujar la pantalla"
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
  Widget _buildPodium() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _PodiumCircle(position: 2, label: 'Top 2', ringColor: AppColors.second, size: 64),
        _PodiumCircle(position: 1, label: 'Líder', ringColor: AppColors.first, size: 88),
        _PodiumCircle(position: 3, label: 'Top 3', ringColor: AppColors.third, size: 64),
      ],
    );
  }
 
  // ---- Chips debajo del podio con nombre y minutos ----
  Widget _buildPodiumPills() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CampusPill(name: 'Las Torres', minutes: 5200, borderColor: AppColors.second),
        _CampusPill(name: 'Laguna', minutes: 5321, borderColor: AppColors.first, highlighted: true),
        _CampusPill(name: 'Toluca', minutes: 4000, borderColor: AppColors.third),
      ],
    );
  }
 
  // ---- Tabla con las posiciones 4 en adelante ----
  Widget _buildRankingList() {
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
          for (int i = 0; i < _restOfRanking.length; i++) ...[
            _RankingRow(data: _restOfRanking[i]),
            if (i != _restOfRanking.length - 1)
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
                  '+20 pts. aportados a Campus Laguna',
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
          // TODO: aquí se conectará con Firebase para guardar la sesión
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