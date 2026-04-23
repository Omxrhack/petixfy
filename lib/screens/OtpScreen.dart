import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:petixfy/services/auth_api.dart';
import 'package:petixfy/services/auth_state.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;
  bool _loading = false;
  String? _email;

  @override
  void initState() {
    super.initState();
    _bootstrapDeepLink();
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
    if (code == null || code.length < 6) return;
    _fillOtp(code.substring(0, 6));
  }

  void _fillOtp(String code) {
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = code[i];
    }
    _verify();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    final email = _email?.trim();
    if (email == null || email.isEmpty) {
      _showError('No se encontró email para verificar OTP');
      return;
    }
    if (_otp.length != 6) {
      _showError('Ingresa un código de 6 dígitos');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthApi.verifyOtp(email: email, token: _otp);
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

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      _controllers[index].text = value.substring(value.length - 1);
    }
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceFirst('Exception: ', '')),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificar código')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Te enviamos un código a ${_email ?? 'tu correo'}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (i) => SizedBox(
                  width: 42,
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: const InputDecoration(counterText: ''),
                    onChanged: (v) => _onDigitChanged(i, v),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _verify,
              child: _loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verificar OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
