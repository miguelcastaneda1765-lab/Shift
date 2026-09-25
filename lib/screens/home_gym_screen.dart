import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_colors.dart';
import '../widgets/FilledPillButton.dart';
import '../widgets/outline_pill_button.dart';
import '../widgets/exercise_placeholder.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/home_header.dart';

/// Cuánto dura un descanso cada vez que se activa "Break".
const int _breakDurationSeconds = 30;

/// Pantalla de gimnasio/entrenamiento activo.
/// Ubicación: lib/screens/home_gym_screen.dart
///
/// [initialTotalSeconds] es el tiempo que ya llevaba corriendo el "Timer
/// total" en la pantalla de Warmup — aquí sigue contando desde ahí.
///
/// Mientras el alumno está en Break, el "Timer total" se pausa
/// automáticamente (no cuenta el descanso como tiempo de entrenamiento);
/// al terminar el break (o cancelarlo con el mismo botón), el total
/// sigue corriendo donde se quedó.
class HomeGymScreen extends StatefulWidget {
  const HomeGymScreen({
    super.key,
    this.campusName = 'Campus Laguna',
    this.userName = 'Andrea',
    this.streakDays = 14,
    this.initialTotalSeconds = 0,
    this.alumnoId = '',
    this.campusId = '',
  });

  final String campusName;
  final String userName;
  final int streakDays;
  final int initialTotalSeconds;
  final String alumnoId;
  final String campusId;

  @override
  State<HomeGymScreen> createState() => _HomeGymScreenState();
}

class _HomeGymScreenState extends State<HomeGymScreen> {
  late int _totalElapsed = widget.initialTotalSeconds;
  bool _totalPaused = false;

  bool _onBreak = false;
  int _breakRemaining = 0;
  bool _breakPaused = false;

  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _onTick() {
    if (!mounted) return;
    setState(() {
      // El total NO avanza mientras está en break — el descanso no cuenta
      // como tiempo de entrenamiento.
      if (!_totalPaused && !_onBreak) {
        _totalElapsed++;
      }

      if (_onBreak && !_breakPaused && _breakRemaining > 0) {
        _breakRemaining--;
        if (_breakRemaining == 0) {
          _onBreak = false; // el break termina solo, se reanuda el total
        }
      }
    });
  }

  void _handleBreak() {
    setState(() {
      if (_onBreak) {
        // Ya estaba en break: este toque lo cancela antes de tiempo.
        _onBreak = false;
        _breakRemaining = 0;
      } else {
        _onBreak = true;
        _breakRemaining = _breakDurationSeconds;
        _breakPaused = false;
      }
    });
  }

  Future<void> _handleStop() async {
    // Convertimos segundos a minutos completos. Con round() en vez de
    // ~/ (división entera), una sesión de 1:35 (95 seg) cuenta como 2 min
    // en vez de perder ese medio minuto redondeando siempre hacia abajo.
    final int minutos = (_totalElapsed / 60).round();

    if (minutos > 0 && widget.campusId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('CampusRanking')
          .doc(widget.campusId)
          .update({
            'MinutesWeek': FieldValue.increment(minutos),
            'MinutesMonth': FieldValue.increment(minutos),
          });

      // Solo si ya tenemos el ID del alumno (pendiente de resolver en
      // Login) también actualizamos su acumulado personal.
      if (widget.alumnoId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('Alumnos')
            .doc(widget.alumnoId)
            .update({'MinutosTotales': FieldValue.increment(minutos)});
      }
    }

    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
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
          child: Padding(
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
                const ExercisePlaceholder(label: 'Gimnasio'),
                const SizedBox(height: 24),
                OutlinePillButton(
                  label: _onBreak
                      ? 'Break: ${_formatTime(_breakRemaining)}${_breakPaused ? ' (en pausa)' : ''}'
                      : 'Break: --',
                  onPressed: _onBreak
                      ? () => setState(() => _breakPaused = !_breakPaused)
                      : () {},
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
                  label: _onBreak ? 'Cancelar break' : 'Break',
                  onPressed: _handleBreak,
                  textColor: AppColors.lyricwhite,
                ),
                const SizedBox(height: 16),
                FilledPillButton(
                  label: 'Stop',
                  onPressed: _handleStop,
                  backgroundColor: AppColors.fight,
                  textColor: AppColors.lyricwhite,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (index) =>
            Navigator.of(context).popUntil((route) => route.isFirst),
      ),
    );
  }
}