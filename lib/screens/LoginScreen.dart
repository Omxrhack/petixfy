import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petixfy/providers/auth_provider.dart';
import 'package:petixfy/theme/app_colors.dart';
import 'package:petixfy/utils/animations.dart';
import 'package:petixfy/widgets/auth/animated_illustration.dart';
import 'package:petixfy/widgets/auth/auth_scaffold.dart';
import 'package:petixfy/widgets/auth/labeled_text_field.dart';
import 'package:petixfy/widgets/onboarding/onboarding_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _showError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _showError = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _showError = false);
      });
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final outcome = await authProvider.signIn(
      email: email,
      password: _passwordController.text,
    );

    if (!mounted) return;

    switch (outcome) {
      case LoginOutcome.emailNotConfirmed:
        _showInfo(
          authProvider.errorMessage ??
              'Tu correo no está verificado. Ingresa el código que te enviamos.',
        );
        Navigator.pushReplacementNamed(
          context,
          'OtpScreen',
          arguments: {'email': email},
        );
        return;
      case LoginOutcome.rateLimited:
        _showError(
          authProvider.errorMessage ??
              'Has pedido demasiados códigos. Espera unos minutos.',
        );
        return;
      case LoginOutcome.error:
        _showError(authProvider.errorMessage ?? 'No se pudo iniciar sesión');
        return;
      case LoginOutcome.success:
        break;
    }

    final user = authProvider.currentUser;
    if (user == null) return;

    if (!user.isVerified) {
      Navigator.pushReplacementNamed(
        context,
        'OtpScreen',
        arguments: {'email': user.email},
      );
    } else if (!user.onboardingCompleted) {
      Navigator.pushReplacementNamed(context, 'ClientOnboardingScreen');
    } else {
      Navigator.pushReplacementNamed(context, 'HomeScreen');
    }
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoading;
    final textTheme = Theme.of(context).textTheme;

    return AuthScaffold(
      title: 'Iniciar sesión',
      subtitle: 'Accede con tu correo y contraseña',
      onBack: () => Navigator.maybePop(context),
      illustration: const AnimatedIllustration(
        imagePath: 'assets/perro-gato.png',
        height: 140,
      ),
      bottom: AppAnimations.fadeIn(
        delay: const Duration(milliseconds: 600),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿No tienes cuenta?',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => Navigator.pushNamed(context, 'RegisterScreen'),
              child: Text(
                'Regístrate',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShakeAnimation(
              trigger: _showError,
              child: AppAnimations.slideIn(
                from: const Offset(0, 0.2),
                delay: const Duration(milliseconds: 200),
                child: AuthFormCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LabeledTextField(
                        label: 'Correo electrónico',
                        controller: _emailController,
                        hintText: 'tu@correo.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'Ingresa tu correo';
                          if (!v.contains('@')) return 'Correo no válido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      LabeledTextField(
                        label: 'Contraseña',
                        controller: _passwordController,
                        hintText: 'Tu contraseña',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _login(),
                        suffixIcon: AnimatedSwitcher(
                          duration: AppAnimations.fast,
                          transitionBuilder: (child, animation) {
                            return RotationTransition(
                              turns: Tween<double>(begin: 0.8, end: 1.0)
                                  .animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: IconButton(
                            key: ValueKey(_obscurePassword),
                            tooltip: _obscurePassword
                                ? 'Mostrar contraseña'
                                : 'Ocultar contraseña',
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(
                                  () => _obscurePassword = !_obscurePassword);
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu contraseña';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            AppAnimations.slideIn(
              from: const Offset(0, 0.3),
              delay: const Duration(milliseconds: 400),
              child: OnboardingPrimaryButton(
                text: 'Entrar',
                icon: Icons.login,
                isLoading: isLoading,
                onPressed: isLoading ? null : _login,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
