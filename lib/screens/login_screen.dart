import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_colors.dart';
import '../widgets/FilledPillButton.dart';
import '../widgets/rounded_text_field.dart';
import 'main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('Alumnos')
          .where('Usuario', isEqualTo: _userController.text.trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Usuario no encontrado')));
        return;
      }

      final alumnoDoc = query.docs.first;
      // .data() nunca incluye el ID del documento — Firestore lo guarda
      // aparte de los campos. Lo agregamos aquí a mano, con la llave
      // 'id', que es justo lo que esperan HomeScreen/HomeGymScreen para
      // saber a qué alumno sumarle sus minutos.
      final alumnoData = {...alumnoDoc.data(), 'id': alumnoDoc.id};
      final storedPassword = alumnoData['Contraseña']?.toString().trim();

      final enteredPassword = _passwordController.text.trim();

      // Debug opcional para verificar valores
      print('Contraseña en BD: "$storedPassword"');
      print('Contraseña ingresada: "$enteredPassword"');

      if (storedPassword != null &&
          storedPassword.toLowerCase() == enteredPassword.toLowerCase()) {
        // ✅ Contraseña correcta → obtener datos del campus
        final DocumentReference campusRef = alumnoData['Campus'];
        final campusDoc = await campusRef.get();
        final campusData = campusDoc.data() as Map<String, dynamic>?;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigationScreen(
              alumnoData: alumnoData,
              campusData: campusData,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Contraseña incorrecta')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _handleForgotPassword() {}
  void _handleMicrosoftLogin() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const _GradientLogo(),
              const SizedBox(height: 24),
              const Text(
                'Hagámoslo juntos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '¿Estás listo para conectar con tu comunidad\n'
                'Tecmilenio a través del movimiento?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              RoundedTextField(
                hintText: 'Usuario',
                controller: _userController,
              ),
              const SizedBox(height: 16),
              RoundedTextField(
                hintText: 'Contraseña',
                obscureText: true,
                controller: _passwordController,
                trailingLabel: 'Olvidé mi contraseña',
                onTrailingTap: _handleForgotPassword,
              ),
              const SizedBox(height: 24),
              FilledPillButton(label: 'Ingresar', onPressed: _handleLogin),
              const SizedBox(height: 32),
              const _OrDivider(),
              const SizedBox(height: 24),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _handleMicrosoftLogin,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(
                    Icons.window_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  label: const Text(
                    'Microsoft 365',
                    style: TextStyle(
                      color: AppColors.lyricwhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                  children: const [
                    TextSpan(text: 'Al ingresar estás de acuerdo con el '),
                    TextSpan(
                      text: 'código de honor',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(text: ' de tu campus\nTecmilenio'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo con degradado teal-verde.
class _GradientLogo extends StatelessWidget {
  const _GradientLogo();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: AppColors.logoGradient,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bounds),
      child: const Text(
        'Side\nby\nSide',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          height: 0.95,
        ),
      ),
    );
  }
}

/// Separador "O continúa con".
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final Color lineColor = AppColors.lyricwhite.withValues(alpha: 0.3);

    return Row(
      children: [
        Expanded(child: Divider(color: lineColor, thickness: 1)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'O continúa con',
            style: TextStyle(
              color: AppColors.lyricwhite,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: lineColor, thickness: 1)),
      ],
    );
  }
}