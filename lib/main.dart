import 'package:flutter/material.dart';
import 'screens/ranking_screen.dart';
 
void main() {
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
      home: const RankingScreen(),
    );
  }
}