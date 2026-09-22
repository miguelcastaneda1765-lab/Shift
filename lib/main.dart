import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // SÍ se agrega
import 'core/constants/app_colors.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/home_gym_screen.dart';
import 'features/home/presentation/screens/home_warmup_screen.dart';

void main() {
  runApp(const SideBySideApp());
}

class SideBySideApp extends StatelessWidget {
  const SideBySideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Side by Side',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryTeal,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Poppins', // swap for the real brand font
      ),
      // Named routes make it easy to jump straight to any of the
      // three screens delivered in this task.
      initialRoute: '/home/gym',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home/warmup': (_) => const HomeWarmupScreen(),
        '/home/gym': (_) => const HomeGymScreen(),
      },
    );
  }
}
