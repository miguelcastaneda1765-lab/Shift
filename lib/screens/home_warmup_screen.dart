import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/FilledPillButton.dart';
import '../widgets/outline_pill_button.dart';
import '../widgets/exercise_placeholder.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/home_header.dart';
import 'home_gym_screen.dart';

/// Cuánto dura el calentamiento antes de pasar solo a Gimnasio.
const int _warmupDurationSeconds = 60; // 1 minuto

/// Pantalla de calentamiento (warm-up).
/// Ubicación: lib/screens/home_warmup_screen.dart
///
/// Dos timers corren en paralelo desde que se abre la pantalla:
/// - "Timer calentamiento": cuenta HACIA ATRÁS desde 1 minuto. Al llegar
///   a 0, navega sola a HomeGymScreen.
/// - "Timer total": cuenta HACIA ADELANTE desde 0, y sigue corriendo (se le
///   pasa su valor a HomeGymScreen para que continúe ahí sin reiniciarse).
///
/// Tocar cualquiera de los dos botones de timer lo pausa/reanuda — cada
/// uno de forma independiente. El botón "Skip" salta directo a Gimnasio
/// sin esperar a que el calentamiento termine.
class HomeWarmupScreen extends StatefulWidget {
  const HomeWarmupScreen({
    super.key,
    this.campusName = 'Campus Laguna',
    this.userName = 'Andrea',
    this.streakDays = 14,
    this.alumnoId = '',
    this.campusId = '',
  });

  final String campusName;
  final String userName;
  final int streakDays;
  final String alumnoId;
  final String campusId;

  @override
  State<HomeWarmupScreen> createState() => _HomeWarmupScreenState();
}

class _HomeWarmupScreenState extends State<HomeWarmupScreen> {
  int _warmupRemaining = _warmupDurationSeconds;
  int _totalElapsed = 0;
  bool _warmupPaused = false;
  bool _totalPaused = false;

  // Evita navegar dos veces si, por ejemplo, tocas Skip justo cuando el
  // timer de calentamiento está por llegar a 0.
  bool _navigated = false;

  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Un solo Timer.periodic controla ambos contadores; cada uno respeta
    // su propia bandera de pausa sin afectar al otro.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  @override
  void dispose() {
    // Muy importante: si no cancelas el Timer aquí, sigue corriendo (y
    // llamando setState) después de que la pantalla ya se cerró, lo que
    // truena la app con un error de "setState after dispose".
    _ticker?.cancel();
    super.dispose();
  }

  void _onTick() {
    if (!mounted) return;
    setState(() {
      if (!_totalPaused) {
        _totalElapsed++;
      }
      if (!_warmupPaused && _warmupRemaining > 0) {
        _warmupRemaining--;
        if (_warmupRemaining == 0) {
          _goToGym();
        }
      }
    });
  }

  void _goToGym() {
    if (_navigated) return;
    _navigated = true;
    _ticker?.cancel();
    // pushReplacement (no push): al terminar el calentamiento no tiene
    // sentido poder "regresar" a él con el botón de atrás.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeGymScreen(
          campusName: widget.campusName,
          userName: widget.userName,
          streakDays: widget.streakDays,
          initialTotalSeconds: _totalElapsed,
          alumnoId: widget.alumnoId,
          campusId: widget.campusId,
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              HomeHeader(
                campusName: widget.campusName,
                userName: widget.userName,
                streakDays: widget.streakDays,
              ),
              const SizedBox(height: 24),
              const ExercisePlaceholder(label: 'Calentamiento'),
              const SizedBox(height: 24),
              OutlinePillButton(
                label: _warmupPaused
                    ? 'Calentamiento: ${_formatTime(_warmupRemaining)} (en pausa)'
                    : 'Calentamiento: ${_formatTime(_warmupRemaining)}',
                onPressed: () => setState(() => _warmupPaused = !_warmupPaused),
              ),
              const SizedBox(height: 16),
              OutlinePillButton(
                label: _totalPaused
                    ? 'Total: ${_formatTime(_totalElapsed)} (en pausa)'
                    : 'Total: ${_formatTime(_totalElapsed)}',
                onPressed: () => setState(() => _totalPaused = !_totalPaused),
              ),
              const SizedBox(height: 16),
              FilledPillButton(
                label: 'Skip',
                onPressed: _goToGym,
                textColor: AppColors.lyricwhite,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        // Esta pantalla se abrió encima de Home (Navigator.push), no es
        // una pestaña más del menú principal — igual que en LockerScreen,
        // tocar cualquier ícono aquí solo regresa.
        onTap: (index) => Navigator.of(context).pop(),
      ),
    );
  }
}