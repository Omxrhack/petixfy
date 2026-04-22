import 'package:flutter/material.dart';
import 'package:petixfy/services/auth_state.dart';

class ValidarScreen extends StatefulWidget {
  const ValidarScreen({Key? key}) : super(key: key);

  @override
  State<ValidarScreen> createState() => _ValidarScreenState();
}

class _ValidarScreenState extends State<ValidarScreen> {
  @override
  void initState() {
    _redirect();
    super.initState();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    if (AuthState.accessToken == null || AuthState.refreshToken == null) {
      Navigator.pushReplacementNamed(context, 'SlashScreens');
      return;
    }

    if (!AuthState.isVerified) {
      Navigator.pushReplacementNamed(
        context,
        'OtpScreen',
        arguments: {'email': AuthState.email},
      );
      return;
    }

    if (!AuthState.onboardingCompleted) {
      Navigator.pushReplacementNamed(context, 'OnboardingScreen');
      return;
    }

    if (AuthState.isVerified && AuthState.onboardingCompleted) {
      Navigator.pushReplacementNamed(context, 'HomeScreen');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(0, 169, 157, 1),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            backgroundColor: Colors.green,
          ),
        ),
      ),
    );
  }
}
