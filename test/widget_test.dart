// Prueba básica: confirma que la app carga y que la pantalla de Ranking
// muestra su título principal.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bienestar_accion/screens/ranking_screen.dart';

void main() {
  testWidgets('La pantalla de Ranking muestra el título', (WidgetTester tester) async {
    // Aquí no usamos MyApp directamente porque MyApp requiere que Firebase
    // ya esté inicializado (eso pasa en main(), no en este test).
    // En su lugar, probamos RankingScreen sola, envuelta en un MaterialApp
    // mínimo para que tenga lo necesario para dibujarse (Directionality, tema, etc.).
    await tester.pumpWidget(
      const MaterialApp(
        home: RankingScreen(),
      ),
    );

    // Verifica que el título "Ranking nacional" esté en pantalla.
    expect(find.text('Ranking nacional'), findsOneWidget);

    // Verifica que el botón de registrar sesión también esté presente.
    expect(find.text('+ Registrar sesión'), findsOneWidget);
  });
}