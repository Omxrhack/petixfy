// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:petixfy/services/auth_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('HomeScreen'),
            ElevatedButton(
              onPressed: () async {
                await AppAuthState.clear();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, 'LoginScreen');
              },
              child: const Text('Cerrar Sesion'),
            )
          ],
        ),
      ),
    );
  }
}
