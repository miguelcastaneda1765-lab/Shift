import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // ⚠️ OBLIGATORIA, si no la pones la app se cierra al arrancar
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
      title: 'Mi Proyecto',
      home: Scaffold(
        appBar: AppBar(title: const Text('Firebase conectado')),
        body: const Center(child: Text('¡Hola mundo!')),
      ),
    );
  }
}