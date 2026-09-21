import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';

/// Pantalla de Home (menú principal).
/// Ubicación: lib/screens/home_screen.dart

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // En el diseño el ícono de la casa es el segundo de la barra
  // (mano, casa, estrella, persona), así que Home = 1.
  // En Ranking la estrella es 2, lo que concuerda con este orden.
  int _selectedNavIndex = 1;

  // TODO: reemplazar estos valores de ejemplo con datos reales
  // (Firebase Auth para el nombre, Firestore para el resto).
  final String _userName = 'Andrea';
  final String _campusName = 'Campus Laguna';
  final int _streakDays = 14;
  final int _routineMinutes = 5;
  final int _dailyGoalMinutes = 45;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              // Espacio para la imagen de la app (hoy el "Mii" del diseño).
              // Ocupa todo el alto disponible entre el encabezado y las
              // tarjetas de abajo, y queda vacío hasta que haya una URL en
              // Firestore.
              const Expanded(child: _HomeImageSlot()),

              _buildRecommendedRoutine(),
              const SizedBox(height: 12),
              _buildStartButton(),
              const SizedBox(height: 16),
              _buildDailyGoal(),
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

  // ---- Encabezado: campus + saludo a la izquierda, racha a la derecha ----
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _campusName,
                style: const TextStyle(color: AppColors.primary, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                '¡Hola, $_userName!',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _StreakBadge(days: _streakDays),
      ],
    );
  }

  // ---- "Rutina recomendada" + chip con la duración ----
  Widget _buildRecommendedRoutine() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Rutina recomendada',
            style: TextStyle(color: AppColors.primary, fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, size: 12, color: Colors.black),
                const SizedBox(width: 4),
                Text(
                  '$_routineMinutes min',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Botón grande "Calentemos juntas" ----
  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: abrir la pantalla de la rutina recomendada / Gimnasio.
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: const Text(
          'Calentemos juntas',
          style: TextStyle(
            color: AppColors.background,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ---- "¿Lista para entrenar?" + tarjeta de meta diaria ----
  Widget _buildDailyGoal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            '¿Lista para entrenar?',
            style: TextStyle(color: AppColors.primary, fontSize: 14),
          ),
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
            'Meta diaria: $_dailyGoalMinutes min.',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGETS PEQUEÑOS, PRIVADOS DE ESTA PANTALLA
// ---------------------------------------------------------------------------

/// Píldora de la esquina superior derecha: "14 días / entrenando juntos".
class _StreakBadge extends StatelessWidget {
  final int days;

  const _StreakBadge({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$days días',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'entrenando juntos',
            style: TextStyle(color: AppColors.primary, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ESPACIO DE IMAGEN CONECTADO A FIRESTORE
// ---------------------------------------------------------------------------
// Escucha el documento app_config/home y lee el campo 'imageUrl'.
// - Sin documento, sin campo o con error: el espacio se queda vacío
//   (mismo tamaño, sin romper el layout).
// - Con una URL válida: muestra la imagen.
//
// OJO: los nombres 'app_config', 'home' e 'imageUrl' son provisionales.
// Tienen que coincidir EXACTAMENTE con lo que se cree en la consola de
// Firebase; si en el equipo ya definieron otros, cámbialos aquí.

class _HomeImageSlot extends StatelessWidget {
  const _HomeImageSlot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('app_config')
            .doc('home')
            .snapshots(),
        builder: (context, snapshot) {
          final String? imageUrl =
              snapshot.data?.data()?['imageUrl'] as String?;

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
      ),
    );
  }
}
