import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_colors.dart';

/// Contenido de la pantalla de Rutinas.
/// Ubicación: lib/screens/rutinas_screen.dart
///
/// OJO: este widget ya NO trae Scaffold ni AppBottomNavBar propios.
/// Se muestra dentro de la pantalla raíz (MainNavigationScreen).
///
/// Ahora es un carrusel vertical: TODAS las rutinas se muestran expandidas
/// (tarjeta grande), una debajo de otra. El campo 'Destacada' de Firestore
/// ya no se usa para decidir el layout — antes decidía cuál rutina salía
/// grande y cuál chica, pero eso ya no aplica. Pueden dejarlo en la base
/// de datos sin problema, el código simplemente lo ignora.

// ---------------------------------------------------------------------------
// MODELO DE DATOS
// ---------------------------------------------------------------------------
// OJO con los acentos y mayúsculas: 'Categoría', 'Descripción' y
// 'DuraciónMin' llevan acento en tu base de datos; 'ImagenURL' y
// 'VideoURL' llevan "URL" en mayúsculas. Tienen que coincidir exacto.

class Routine {
  final String id;
  final String title;
  final String category;
  final String level;
  final int durationMin;
  final String description;
  final String coach;
  final String campus;
  final String imageUrl;
  final String videoUrl;

  const Routine({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.durationMin,
    required this.description,
    required this.coach,
    required this.campus,
    required this.imageUrl,
    required this.videoUrl,
  });

  factory Routine.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data();
    return Routine(
      id: doc.id,
      title: data['Titulo'] as String? ?? 'Rutina',
      category: data['Categoría'] as String? ?? '',
      level: data['Nivel'] as String? ?? '',
      // DuraciónMin viene como decimal (ej. 22.17) en tu base de datos —
      // .round() lo deja en minutos enteros para mostrar ("22 min").
      durationMin: (data['DuraciónMin'] as num?)?.round() ?? 0,
      description: data['Descripción'] as String? ?? '',
      coach: data['Coach'] as String? ?? '',
      campus: data['Campus'] as String? ?? '',
      imageUrl: data['ImagenURL'] as String? ?? '',
      videoUrl: data['VideoURL'] as String? ?? '',
    );
  }
}

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

// ---------------------------------------------------------------------------
// PANTALLA PRINCIPAL
// ---------------------------------------------------------------------------

class RoutinesScreen extends StatefulWidget {
  final Map<String, dynamic> alumnoData;
  final Map<String, dynamic>? campusData;

  const RoutinesScreen({super.key, required this.alumnoData, this.campusData});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  String get _studentDocId => widget.alumnoData['id'] as String? ?? '';

  String _selectedCategory = 'Todas';
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openRoutine(Routine routine) {
    // TODO: abrir la pantalla que reproduce routine.videoUrl
    // (por ejemplo con el paquete video_player).
  }

  /// Agrega o quita una rutina del arreglo de favoritas del alumno.
  Future<void> _toggleFavorite(String routineId, bool isFavorite) async {
    if (_studentDocId.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('Alumnos')
        .doc(_studentDocId)
        .update({
          'RutinasFavoritas': isFavorite
              ? FieldValue.arrayRemove([routineId])
              : FieldValue.arrayUnion([routineId]),
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        // StreamBuilder de afuera: trae las rutinas favoritas del alumno.
        // StreamBuilder de adentro: trae el catálogo completo de rutinas.
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _studentDocId.isEmpty
              ? const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty()
              : FirebaseFirestore.instance
                    .collection('Alumnos')
                    .doc(_studentDocId)
                    .snapshots(),
          builder: (context, alumnoSnapshot) {
            final List<String> favoritas =
                (alumnoSnapshot.data?.data()?['RutinasFavoritas'] as List?)
                    ?.cast<String>() ??
                [];

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('Rutinas')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'No se pudieron cargar las rutinas.\n${snapshot.error}',
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

                final List<Routine> all = snapshot.data!.docs
                    .map(Routine.fromFirestore)
                    .toList();

                final List<String> categories = [
                  'Todas',
                  ...{
                    for (final r in all)
                      if (r.category.isNotEmpty) r.category,
                  },
                ];
                final String selected = categories.contains(_selectedCategory)
                    ? _selectedCategory
                    : 'Todas';

                final String query = _normalize(_query);
                final List<Routine> filtered = all.where((r) {
                  final bool matchesCategory =
                      selected == 'Todas' || r.category == selected;
                  final bool matchesQuery =
                      query.isEmpty ||
                      _normalize('${r.title} ${r.level} ${r.category}')
                          .contains(query);
                  return matchesCategory && matchesQuery;
                }).toList();

                // Favoritas primero, sin revolver el orden entre sí ni
                // el de las no-favoritas.
                final List<Routine> favoritasList = filtered
                    .where((r) => favoritas.contains(r.id))
                    .toList();
                final List<Routine> noFavoritasList = filtered
                    .where((r) => !favoritas.contains(r.id))
                    .toList();
                final List<Routine> ordered = [
                  ...favoritasList,
                  ...noFavoritasList,
                ];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nuestras rutinas',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Selecciona o explora tu próxima sesión',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSearchField(),
                      const SizedBox(height: 14),
                      _buildCategoryChips(categories, selected),
                      const SizedBox(height: 20),
                      if (ordered.isEmpty)
                        _buildEmptyMessage(noRoutinesAtAll: all.isEmpty)
                      else
                        // Carrusel vertical: todas expandidas, una debajo
                        // de otra, favoritas primero.
                        for (final r in ordered)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _RoutineCard(
                              routine: r,
                              isFavorite: favoritas.contains(r.id),
                              onStart: () => _openRoutine(r),
                              onToggleFavorite: () => _toggleFavorite(
                                r.id,
                                favoritas.contains(r.id),
                              ),
                            ),
                          ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    OutlineInputBorder border(double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: BorderSide(color: AppColors.primary, width: width),
    );

    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
      style: const TextStyle(color: AppColors.lyricwhite),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: 'Busca una rutina o nivel...',
        hintStyle: TextStyle(
          color: AppColors.primary.withValues(alpha: 0.7),
          fontSize: 14,
        ),
        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        enabledBorder: border(1),
        focusedBorder: border(2),
      ),
    );
  }

  Widget _buildCategoryChips(List<String> categories, String selected) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in categories)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _CategoryChip(
                label: category,
                isSelected: category == selected,
                icon: category == 'Todas' ? Icons.apps : null,
                onTap: () => setState(() => _selectedCategory = category),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessage({required bool noRoutinesAtAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          noRoutinesAtAll
              ? 'Aún no hay rutinas registradas.'
              : 'No se encontraron rutinas con esos filtros.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.lyricwhite.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGETS PEQUEÑOS, PRIVADOS DE ESTA PANTALLA
// ---------------------------------------------------------------------------

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData? icon;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isSelected
        ? AppColors.background
        : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlineChip extends StatelessWidget {
  final String label;

  const _OutlineChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.primary, fontSize: 11),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  final int minutes;

  const _DurationChip({required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 12, color: AppColors.background),
          const SizedBox(width: 4),
          Text(
            '$minutes min',
            style: const TextStyle(
              color: AppColors.background,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutineImage extends StatelessWidget {
  final String url;

  const _RoutineImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final Widget placeholder = Container(
      color: AppColors.primary.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: const Icon(Icons.fitness_center, color: AppColors.primary),
    );

    if (url.isEmpty) return placeholder;

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}

/// Tarjeta grande de una rutina — ahora TODAS las rutinas se muestran
/// así, en el carrusel vertical (antes solo la "destacada" se veía así
/// de grande, y el resto salían chicas en una lista aparte).
class _RoutineCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onStart;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const _RoutineCard({
    required this.routine,
    required this.onStart,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final String coachLine = [
      if (routine.coach.isNotEmpty) 'Coach ${routine.coach}',
      if (routine.campus.isNotEmpty) routine.campus,
    ].join(' • ');

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _RoutineImage(url: routine.imageUrl),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: onToggleFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.bookmark : Icons.bookmark_border,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  if (routine.durationMin > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _DurationChip(minutes: routine.durationMin),
                    ),
                  if (coachLine.isNotEmpty)
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          coachLine,
                          style: const TextStyle(
                            color: AppColors.background,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    routine.title,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (routine.category.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      routine.category,
                      style: const TextStyle(
                        color: AppColors.background,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (routine.level.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: _OutlineChip(label: routine.level),
            ),
          if (routine.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Text(
                routine.description,
                style: TextStyle(
                  color: AppColors.primary.withValues(alpha: 0.85),
                  fontSize: 11,
                ),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(
                Icons.play_circle_fill,
                color: AppColors.background,
              ),
              label: const Text(
                'Comenzar rutina',
                style: TextStyle(
                  color: AppColors.background,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}