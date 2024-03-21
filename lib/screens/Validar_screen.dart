import 'package:flutter/material.dart';
import 'package:petixfy/main.dart';

class ValidarScreen extends StatefulWidget {
  const ValidarScreen({Key? key}) : super(key: key);

  @override
  State<ValidarScreen> createState() => _ValidarScreenState();
}

class _ValidarScreenState extends State<ValidarScreen> {
  @override
  @override
  void initState() {
    _redirect();
    super.initState();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(seconds: 3));
    final session = supabase.auth.currentSession;
    if (!mounted) return;
    if (session != null) {
      Navigator.pushReplacementNamed(context, 'HomeScreen');
    } else {
      Navigator.pushReplacementNamed(context, 'SlashScreens');
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
