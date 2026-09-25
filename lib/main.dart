import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart'; // 👉 Importamos LoginScreen en lugar de MainNavigationScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bienestar en Acción',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Forma DJR Deck',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const LoginScreen(),
    );
  }
}
