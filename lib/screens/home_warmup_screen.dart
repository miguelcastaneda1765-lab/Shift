import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../theme/app_colors.dart';
import '../widgets/home_header.dart';
import '../widgets/FilledPillButton.dart';
import '../widgets/outline_pill_button.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_gym_screen.dart';

/// Duración del calentamiento: 3 minutos con 30 segundos = 210 segundos
const int _warmupDurationSeconds = 210;

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
  bool _navigated = false;

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
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('Alumnos')
              .doc(widget.alumnoId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final alumnoData = snapshot.data!.data() ?? {};
            final nombre = alumnoData['Usuario'] ?? 'Alumno';
            final racha = alumnoData['RachaDias'] ?? 0;

            final modeloUrl =
                alumnoData['Avatar']?['ModeloUrl'] ??
                alumnoData['Avatar']?['ModeloURL'] ??
                '';

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HomeHeader(
                    campusName: widget.campusName,
                    userName: nombre,
                    streakDays: racha,
                  ),
                  const SizedBox(height: 24),

                  // 👇 Monito 3D en el centro
                  Expanded(
                    child: Center(
                      child: modeloUrl.isNotEmpty
                          ? ModelViewer(
                              key: ValueKey(modeloUrl),
                              src: modeloUrl,
                              alt: "Avatar 3D",
                              autoRotate: true,
                              cameraControls: true,
                              backgroundColor: Colors.transparent,
                            )
                          : Text(
                              'No hay modelo asignado',
                              style: TextStyle(
                                color: AppColors.primary.withOpacity(0.5),
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Timers de calentamiento y total
                  OutlinePillButton(
                    label: _warmupPaused
                        ? 'Calentamiento: ${_formatTime(_warmupRemaining)} (en pausa)'
                        : 'Calentamiento: ${_formatTime(_warmupRemaining)}',
                    onPressed: () =>
                        setState(() => _warmupPaused = !_warmupPaused),
                  ),
                  const SizedBox(height: 16),
                  OutlinePillButton(
                    label: _totalPaused
                        ? 'Total: ${_formatTime(_totalElapsed)} (en pausa)'
                        : 'Total: ${_formatTime(_totalElapsed)}',
                    onPressed: () =>
                        setState(() => _totalPaused = !_totalPaused),
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
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) => Navigator.of(context).pop(),
      ),
    );
  }
}