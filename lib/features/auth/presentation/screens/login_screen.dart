import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/filled_pill_button.dart';
import '../../../../core/widgets/rounded_text_field.dart';

/// "Loggin" screen — matches the provided mock pixel-for-pixel:
/// gradient logo, welcome copy, username/password fields,
/// primary CTA and a Microsoft 365 SSO option.
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

  void _handleLogin() {
    // TODO: wire up real authentication logic.
  }

  void _handleForgotPassword() {
    // TODO: navigate to password recovery flow.
  }

  void _handleMicrosoftLogin() {
    // TODO: wire up Microsoft 365 SSO.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.largeSpacing),
              _GradientLogo(),
              const SizedBox(height: AppSizes.sectionSpacing),
              const Text(
                'Hagámoslo juntos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryTeal,
                  fontSize: AppSizes.fontTitle,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSizes.smallSpacing),
              const Text(
                '¿Estás listo para conectar con tu comunidad\n'
                'Tecmilenio a través del movimiento?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryTeal,
                  fontSize: AppSizes.fontBody,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSizes.sectionSpacing),
              RoundedTextField(
                hintText: 'Usuario',
                controller: _userController,
              ),
              const SizedBox(height: AppSizes.mediumSpacing),
              RoundedTextField(
                hintText: 'Contraseña',
                obscureText: true,
                controller: _passwordController,
                trailingLabel: 'Olvidé mi contraseña',
                onTrailingTap: _handleForgotPassword,
              ),
              const SizedBox(height: AppSizes.sectionSpacing),
              FilledPillButton(
                label: 'Ingresar',
                onPressed: _handleLogin,
              ),
              const SizedBox(height: AppSizes.largeSpacing),
              _OrDivider(),
              const SizedBox(height: AppSizes.sectionSpacing),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _handleMicrosoftLogin,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryTeal),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    ),
                  ),
                  // Placeholder icon — swap for the real Microsoft logo asset.
                  icon: const Icon(
                    Icons.window_rounded,
                    color: AppColors.primaryTeal,
                    size: 18,
                  ),
                  label: const Text(
                    'Microsoft 365',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.largeSpacing),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    color: AppColors.primaryTeal,
                    fontSize: AppSizes.fontSmall,
                  ),
                  children: [
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
              const SizedBox(height: AppSizes.largeSpacing),
            ],
          ),
        ),
      ),
    );
  }
}

/// Big "Side by Side" wordmark rendered with a teal-to-green gradient.
class _GradientLogo extends StatelessWidget {
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
          fontSize: AppSizes.fontLogo,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          height: 0.95,
        ),
      ),
    );
  }
}

/// "O continúa con" divider with horizontal rules on both sides.
class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'O continúa con',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: AppSizes.fontBody,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
      ],
    );
  }
}
