import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';

/// Pantalla de Rutinas.
/// Ubicación: lib/screens/routines_screen.dart

// ---------------------------------------------------------------------------
// MODELO DE DATOS
// ---------------------------------------------------------------------------
// Representa un documento de la colección "Rutinas" de Firestore.
// Los nombres de los campos tienen que coincidir EXACTAMENTE con los de la
// consola de Firebase (mayúsculas incluidas, sin acentos).

class Routine {
  final String id;
  final String title;
  final String category;
  final String sportCategory;
  final String level;
  final int durationMin;
  final String description;
  final String coach;
  final String campus;
  final bool featured;
  final String imageUrl;
  final String videoUrl;

  const Routine({
    required this.id,
    required this.title,
    required this.category,
    required this.sportCategory,
    required this.level,
    required this.durationMin,
    required this.description,
    required this.coach,
    required this.campus,
    required this.featured,
    required this.imageUrl,
    required this.videoUrl,
  });

  factory Routine.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data();
    return Routine(
      id: doc.id,
      title: data['Titulo'] as String? ?? 'Rutina',
      category: data['Categoría'] as String? ?? '',
      sportCategory: data['TipoDeporte'] as String? ?? '',
      level: data['Nivel'] as String? ?? '',
      durationMin: (data['DuraciónMin'] as num?)?.round() ?? 0,
      description: data['Descripción'] as String? ?? '',
      coach: data['Coach'] as String? ?? '',
      campus: data['Campus'] as String? ?? '',
      featured: data['Destacada'] as bool? ?? false,
      imageUrl: data['ImagenURL'] as String? ?? '',
      videoUrl: data['VideoURL'] as String? ?? '',
    );
  }
}

/// Quita mayúsculas y acentos para comparar textos en la búsqueda:
/// "Básico" y "basico" cuentan como lo mismo.
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

/// Categoría de deporte -> color (los mismos 5 grupos y colores que se
/// usan en la pantalla de Perfil). Busca por palabra clave, así que
/// "Confrontación" o "Confrontación de equipos" dan el mismo color.
Color _colorForSportCategory(String? category) {
  if (category == null || category.isEmpty) return AppColors.primary;
  final String c = _normalize(category);

  if (c.contains('rendimiento') || c.contains('tiempo')) {
    return AppColors.performance; // verde
  }
  if (c.contains('confrontacion') || c.contains('equipos')) {
    return AppColors.teams; // naranja
  }
  if (c.contains('combate')) {
    return AppColors.fight; // rojo
  }
  if (c.contains('acondicionamiento')) {
    return AppColors.physicalFitness; // azul
  }
  if (c.contains('expresion') || c.contains('tecnico')) {
    return AppColors.expression; // amarillo
  }
  return AppColors.primary;
}

// ---------------------------------------------------------------------------
// PANTALLA PRINCIPAL
// ---------------------------------------------------------------------------

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  // En el diseño el ícono de la mano es el primero de la barra
  // (mano, casa, estrella, persona), así que Rutinas = 0.
  int _selectedNavIndex = 0;

  // Filtros: chip de categoría, chip de tipo de deporte y texto de la
  // búsqueda.
  String _selectedCategory = 'Todas';
  String _selectedSport = 'Todos';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // Escucha la colección completa en tiempo real. Los filtros se
        // aplican aquí mismo, en la app, sobre la lista que llegó.
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('Rutinas').snapshots(),
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

            final List<Routine> all =
                snapshot.data!.docs.map(Routine.fromFirestore).toList();

            // Los chips salen de las categorías que existen en la base de
            // datos: si alguien crea una categoría nueva, aparece sola.
            final List<String> categories = [
              'Todas',
              ...{
                for (final r in all)
                  if (r.category.isNotEmpty) r.category,
              },
            ];
            final String selected =
                categories.contains(_selectedCategory) ? _selectedCategory : 'Todas';

            // Igual que las categorías, pero con el campo TipoDeporte.
            final List<String> sportCategories = [
              'Todos',
              ...{
                for (final r in all)
                  if (r.sportCategory.isNotEmpty) r.sportCategory,
              },
            ];
            final String selectedSport = sportCategories.contains(_selectedSport)
                ? _selectedSport
                : 'Todos';

            // Filtro por categoría + tipo de deporte + búsqueda por texto
            // (título, nivel o categoría).
            final String query = _normalize(_query);
            final List<Routine> filtered = all.where((r) {
              final bool matchesCategory =
                  selected == 'Todas' || r.category == selected;
              final bool matchesSport =
                  selectedSport == 'Todos' || r.sportCategory == selectedSport;
              final bool matchesQuery = query.isEmpty ||
                  _normalize('${r.title} ${r.level} ${r.category}').contains(query);
              return matchesCategory && matchesSport && matchesQuery;
            }).toList();

            // La rutina destacada es la primera marcada como Destacada que
            // pase los filtros; el resto va en la lista de abajo.
            final List<Routine> featuredList =
                filtered.where((r) => r.featured).toList();
            final Routine? featured =
                featuredList.isEmpty ? null : featuredList.first;
            final List<Routine> others =
                filtered.where((r) => r.id != featured?.id).toList();

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
                    style: TextStyle(color: AppColors.primary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  _buildSearchField(),
                  const SizedBox(height: 14),
                  _buildCategoryChips(categories, selected),
                  // Mientras ninguna rutina tenga TipoDeporte, esta fila
                  // solo tendría "Todos" y se vería como un duplicado de
                  // "Todas". Se muestra solo cuando hay opciones reales.
                  if (sportCategories.length > 1) ...[
                    const SizedBox(height: 10),
                    _buildSportChips(sportCategories, selectedSport),
                  ],
                  const SizedBox(height: 20),

                  if (filtered.isEmpty)
                    _buildEmptyMessage(noRoutinesAtAll: all.isEmpty)
                  else ...[
                    if (featured != null) ...[
                      _buildFeaturedHeader(featured),
                      const SizedBox(height: 12),
                      _FeaturedCard(
                        routine: featured,
                        onStart: () => _openRoutine(featured),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (others.isNotEmpty) ...[
                      const Text(
                        '¡Prueba rutinas diferentes!',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final r in others)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RoutineListTile(
                            routine: r,
                            onTap: () => _openRoutine(r),
                          ),
                        ),
                    ],
                  ],
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

  // ---- Barra de búsqueda ----
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

  // ---- Chips de categoría (con scroll horizontal) ----
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

  // ---- Chips de tipo de deporte (con scroll horizontal y color) ----
  Widget _buildSportChips(List<String> sportCategories, String selected) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final sport in sportCategories)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _SportChip(
                label: sport,
                color: sport == 'Todos'
                    ? AppColors.primary
                    : _colorForSportCategory(sport),
                isSelected: sport == selected,
                onTap: () => setState(() => _selectedSport = sport),
              ),
            ),
        ],
      ),
    );
  }

  // ---- "Rutina destacada" + nivel ----
  Widget _buildFeaturedHeader(Routine featured) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 12, color: AppColors.primary),
        const SizedBox(width: 8),
        const Text(
          'Rutina destacada',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (featured.level.isNotEmpty) _OutlineChip(label: featured.level),
      ],
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

/// Chip de filtro: relleno cuando está seleccionado, solo borde si no.
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
    final Color textColor =
        isSelected ? AppColors.background : AppColors.primary;

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

/// Chip de tipo de deporte: usa el color de su categoría (los mismos
/// colores que en Perfil), relleno cuando está seleccionado.
class _SportChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SportChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // El texto blanco no se lee sobre el amarillo, ahí va oscuro.
    final bool useLightText = color != AppColors.expression;
    final Color textColor = isSelected
        ? (useLightText ? Colors.white : AppColors.background)
        : color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

/// Pastilla con solo borde (nivel de la rutina).
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

/// Pastilla rellena con reloj y minutos.
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

/// Imagen de la rutina (miniatura). Si no hay URL o falla la carga, se
/// dibuja un recuadro con un ícono para no romper el diseño.
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

/// Tarjeta grande de la rutina destacada.
class _FeaturedCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onStart;

  const _FeaturedCard({required this.routine, required this.onStart});

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
                  const Positioned(
                    top: 8,
                    left: 8,
                    child: Icon(Icons.bookmark_border, color: AppColors.primary),
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
          if (routine.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
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

/// Fila de la lista "¡Prueba rutinas diferentes!".
class _RoutineListTile extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;

  const _RoutineListTile({required this.routine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 56,
                height: 56,
                child: _RoutineImage(url: routine.imageUrl),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (routine.category.isNotEmpty)
                    Text(
                      routine.category,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                      ),
                    ),
                  Text(
                    routine.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (routine.level.isNotEmpty)
                        _OutlineChip(label: routine.level),
                      if (routine.durationMin > 0)
                        _DurationChip(minutes: routine.durationMin),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.primary, size: 30),
          ],
        ),
      ),
    );
  }
}
