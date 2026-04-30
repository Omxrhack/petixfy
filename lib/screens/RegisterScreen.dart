import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petixfy/providers/auth_provider.dart';
import 'package:petixfy/theme/app_colors.dart';
import 'package:petixfy/utils/animations.dart';
import 'package:petixfy/widgets/auth/animated_illustration.dart';
import 'package:petixfy/widgets/auth/auth_scaffold.dart';
import 'package:petixfy/widgets/auth/labeled_text_field.dart';
import 'package:petixfy/widgets/onboarding/onboarding_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _showError = false;
  double _passwordStrength = 0.0;

  static const int _minPasswordLength = 8;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    double strength = 0.0;

    if (password.isEmpty) {
      strength = 0.0;
    } else if (password.length < 6) {
      strength = 0.25;
    } else if (password.length < 8) {
      strength = 0.5;
    } else {
      strength = 0.75;
      if (password.contains(RegExp(r'[A-Z]')) &&
          password.contains(RegExp(r'[0-9]'))) {
        strength = 1.0;
      }
    }

    if (mounted) {
      setState(() => _passwordStrength = strength);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _showError = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _showError = false);
      });
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final outcome = await authProvider.register(
      email: email,
      password: password,
    );

    if (!mounted) return;

    switch (outcome) {
      case RegisterOutcome.goToOtp:
        if (authProvider.lastRegisterAlreadyExisted) {
          _showInfo(
            'Ese correo ya estaba registrado pero no verificado. '
            'Usa el último código que recibiste o pide uno nuevo desde la pantalla siguiente.',
            duration: const Duration(seconds: 6),
          );
        }
        Navigator.pushNamed(
          context,
          'OtpScreen',
          arguments: {'email': email},
        );
        return;
      case RegisterOutcome.alreadyVerified:
        _showInfo(
          authProvider.errorMessage ??
              'Este correo ya está registrado. Inicia sesión.',
        );
        Navigator.pushReplacementNamed(context, 'LoginScreen');
        return;
      case RegisterOutcome.rateLimited:
        _showError(
          authProvider.errorMessage ??
              'Has pedido demasiados códigos. Espera unos minutos.',
        );
        return;
      case RegisterOutcome.error:
        _showError(authProvider.errorMessage ?? 'No se pudo registrar');
        return;
    }
  }

  void _showInfo(String message, {Duration? duration}) {
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
          duration: duration ?? const Duration(seconds: 4),
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
      title: 'Crear cuenta',
      subtitle: 'Te enviaremos un código para verificar tu correo',
      onBack: () => Navigator.maybePop(context),
      illustration: const AnimatedIllustration(
        imagePath: 'assets/mujer-perro.png',
        height: 150,
      ),
      bottom: AppAnimations.fadeIn(
        delay: const Duration(milliseconds: 600),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿Ya tienes cuenta?',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () =>
                      Navigator.pushReplacementNamed(context, 'LoginScreen'),
              child: Text(
                'Inicia sesión',
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LabeledTextField(
                        label: 'Contraseña',
                        controller: _passwordController,
                        hintText: 'Mínimo $_minPasswordLength caracteres',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        autofillHints: const [AutofillHints.newPassword],
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
                          final v = value ?? '';
                          if (v.isEmpty) return 'Ingresa una contraseña';
                          if (v.length < _minPasswordLength) {
                            return 'La contraseña debe tener al menos '
                                '$_minPasswordLength caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: AppAnimations.medium,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: AppColors.borderLight,
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _passwordStrength,
                          child: AnimatedContainer(
                            duration: AppAnimations.medium,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: _passwordStrength < 0.5
                                  ? AppColors.error
                                  : _passwordStrength < 0.75
                                      ? AppColors.warning
                                      : AppColors.success,
                            ),
                          ),
                        ),
                      ),
                      if (_passwordController.text.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        AnimatedSwitcher(
                          duration: AppAnimations.fast,
                          child: Text(
                            key: ValueKey(_passwordStrength),
                            _passwordStrength == 0
                                ? ''
                                : _passwordStrength < 0.5
                                    ? 'Débil'
                                    : _passwordStrength < 0.75
                                        ? 'Media'
                                        : _passwordStrength < 1.0
                                            ? 'Buena'
                                            : 'Fuerte',
                            style: textTheme.bodySmall?.copyWith(
                              color: _passwordStrength < 0.5
                                  ? AppColors.error
                                  : _passwordStrength < 0.75
                                      ? AppColors.warning
                                      : AppColors.success,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  LabeledTextField(
                    label: 'Confirmar contraseña',
                    controller: _confirmPasswordController,
                    hintText: 'Vuelve a escribir tu contraseña',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    onFieldSubmitted: (_) => _submit(),
                    suffixIcon: _confirmPasswordController.text.isNotEmpty &&
                            _confirmPasswordController.text ==
                                _passwordController.text
                        ? AnimatedSwitcher(
                            duration: AppAnimations.fast,
                            child: const Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              key: ValueKey('check'),
                            ),
                          )
                        : AnimatedSwitcher(
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
                              key: ValueKey(_obscureConfirm),
                              tooltip: _obscureConfirm
                                  ? 'Mostrar contraseña'
                                  : 'Ocultar contraseña',
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                setState(
                                    () => _obscureConfirm = !_obscureConfirm);
                              },
                            ),
                          ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
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
                text: 'Registrarme',
                icon: Icons.person_add_alt_1,
                isLoading: isLoading,
                onPressed: isLoading ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
