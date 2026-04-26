import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petixfy/providers/auth_provider.dart';
import 'package:petixfy/services/auth_api.dart';
import 'package:petixfy/services/auth_state.dart';
import 'package:petixfy/theme/app_colors.dart';
import 'package:petixfy/widgets/auth/auth_scaffold.dart';
import 'package:petixfy/widgets/auth/labeled_text_field.dart';
import 'package:petixfy/widgets/auth/otp_box.dart';
import 'package:petixfy/widgets/onboarding/onboarding_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // El proyecto Supabase remoto está configurado para enviar OTPs de 8
  // dígitos. Si lo cambias en el dashboard de Supabase a 6, ajusta este
  // valor para que coincida.
  static const int _otpLength = 8;
  static const int _resendCountdown = 30;

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;

  bool _loading = false;
  bool _resending = false;
  String? _email;

  Timer? _timer;
  int _secondsLeft = _resendCountdown;

  @override
  void initState() {
    super.initState();
    _bootstrapDeepLink();
    _startCountdown();
  }

  Future<void> _bootstrapDeepLink() async {
    try {
      final initial = await _appLinks.getInitialAppLink();
      if (initial != null) {
        _tryFillFromUri(initial);
      }
      _linkSub = _appLinks.uriLinkStream.listen(_tryFillFromUri);
    } catch (_) {
      // Ignore deep link startup issues and keep manual OTP entry.
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendCountdown);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['email'] is String) {
      _email = args['email'] as String;
    }
    _email ??= AppAuthState.email;
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _tryFillFromUri(Uri uri) {
    final code = uri.queryParameters['code'] ?? uri.queryParameters['token'];
    if (code == null || code.length < _otpLength) return;
    _fillOtp(code.substring(0, _otpLength));
  }

  void _fillOtp(String code) {
    for (int i = 0; i < _otpLength; i++) {
      _controllers[i].text = code[i];
    }
    setState(() {});
    _verify();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    final email = _email?.trim();
    if (email == null || email.isEmpty) {
      _showError('No se encontró un correo para verificar el OTP');
      return;
    }
    if (_otp.length != _otpLength) {
      _showError('Ingresa los $_otpLength dígitos del código');
      return;
    }

    setState(() => _loading = true);
    try {
      final data = await AuthApi.verifyOtp(email: email, token: _otp);
      if (!mounted) return;
      await context.read<AuthProvider>().adoptSessionFromVerify(data);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, 'ClientOnboardingScreen');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _onCompleted(String code) {
    if (!_loading) {
      _verify();
    }
  }

  Future<void> _resend() async {
    final email = _email?.trim();
    if (email == null || email.isEmpty) {
      _showError('No se encontró un correo para reenviar el código');
      return;
    }
    if (_resending) return;

    setState(() => _resending = true);
    final outcome = await context.read<AuthProvider>().resendOtp(email);
    if (!mounted) return;
    setState(() => _resending = false);

    switch (outcome) {
      case ResendOtpOutcome.sent:
        _showInfo('Te reenviamos un nuevo código a $email');
        _startCountdown();
        return;
      case ResendOtpOutcome.rateLimited:
        _showError(
          context.read<AuthProvider>().errorMessage ??
              'Has pedido demasiados códigos. Espera unos minutos.',
        );
        return;
      case ResendOtpOutcome.error:
        _showError(
          context.read<AuthProvider>().errorMessage ??
              'No se pudo reenviar el código',
        );
        return;
    }
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            maxLines: 2,
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
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message.replaceFirst('Exception: ', ''),
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
    final textTheme = Theme.of(context).textTheme;
    final email = _email ?? 'tu correo';

    return AuthScaffold(
      title: 'Verificar correo',
      subtitle: 'Te enviamos un código a $email',
      headerIcon: Icons.mark_email_read_outlined,
      onBack: () => Navigator.maybePop(context),
      bottom: TextButton(
        onPressed: _loading ? null : () => Navigator.maybePop(context),
        child: Text(
          'Cambiar correo',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthFormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.mail_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ingresa el código de $_otpLength dígitos que enviamos a tu correo.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                OtpBoxGroup(
                  length: _otpLength,
                  controllers: _controllers,
                  focusNodes: _focusNodes,
                  onCompleted: _onCompleted,
                ),
                const SizedBox(height: 24),
                OnboardingPrimaryButton(
                  text: 'Verificar',
                  icon: Icons.check_circle_outline,
                  isLoading: _loading,
                  onPressed: _loading ? null : _verify,
                ),
                const SizedBox(height: 16),
                Center(
                  child: _secondsLeft > 0
                      ? Text(
                          '¿No te llegó? Reenviar en ${_secondsLeft}s',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 14,
                          ),
                        )
                      : TextButton(
                          onPressed:
                              (_loading || _resending) ? null : _resend,
                          child: _resending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Reenviar código',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
