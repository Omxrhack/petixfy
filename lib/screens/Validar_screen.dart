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
    if (AppAuthState.accessToken == null || AppAuthState.refreshToken == null) {
      Navigator.pushReplacementNamed(context, 'SlashScreens');
      return;
    }

    if (!AppAuthState.isVerified) {
      Navigator.pushReplacementNamed(
        context,
        'OtpScreen',
        arguments: {'email': AppAuthState.email},
      );
      return;
    }

    if (!AppAuthState.onboardingCompleted) {
      Navigator.pushReplacementNamed(context, 'ClientOnboardingScreen');
      return;
    }

    if (AppAuthState.isVerified && AppAuthState.onboardingCompleted) {
      Navigator.pushReplacementNamed(context, 'HomeScreen');
    }
  }

  @override
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
