import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/ranking_screen.dart';
import 'screens/home_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/rutinas_screen.dart';

void main() async {
  // OBLIGATORIA: si no la pones, la app se cierra al arrancar.
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bienestar en Acción',
      debugShowCheckedModeBanner: false, // quita la cinta roja de "Debug"
      theme: ThemeData(
        fontFamily: 'Forma DJR Deck',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const RoutinesScreen(),
    );
  }
}