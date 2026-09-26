import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../theme/app_colors.dart';
import '../widgets/FilledPillButton.dart';
import '../widgets/outline_pill_button.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/home_header.dart';

const int _breakDurationSeconds = 30;

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
      if (!_totalPaused && !_onBreak) {
        _totalElapsed++;
      }
      if (_onBreak && !_breakPaused && _breakRemaining > 0) {
        _breakRemaining--;
        if (_breakRemaining == 0) {
          _onBreak = false;
        }
      }
    });
  }

  void _handleBreak() {
    setState(() {
      if (_onBreak) {
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
    final int minutos = (_totalElapsed / 60).round();

    if (minutos > 0 && widget.campusId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('CampusRanking')
          .doc(widget.campusId)
          .update({
            'MinutesWeek': FieldValue.increment(minutos),
            'MinutesMonth': FieldValue.increment(minutos),
          });

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
    final campusRef = FirebaseFirestore.instance
        .collection('CampusRanking')
        .doc(widget.campusId);

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

                // 👇 Imagen de gym con todos los monitos adentro
                Container(
                  height: 300, // más grande
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/gym.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('Alumnos')
                        .where('Campus', isEqualTo: campusRef)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }

                      // Incluimos al usuario actual + compañeros
                      final docs = snapshot.data!.docs;
                      final allPlayers = docs.take(3).toList(); // máximo 3

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: allPlayers.map((doc) {
                          final data = doc.data();
                          final modeloUrl =
                              data['Avatar']?['ModeloUrl'] ??
                              data['Avatar']?['ModeloURL'] ??
                              '';
                          return SizedBox(
                            height: 120,
                            width: 100,
                            child: modeloUrl.isNotEmpty
                                ? ModelViewer(
                                    src: modeloUrl,
                                    alt: "Avatar",
                                    autoRotate: true,
                                    cameraControls: false,
                                    backgroundColor: Colors.transparent,
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),

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
        currentIndex: 0, // Home sigue marcado
        onTap: (index) =>
            Navigator.of(context).popUntil((route) => route.isFirst),
      ),
    );
  }
}