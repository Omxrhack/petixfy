// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:petixfy/main.dart';

import '../routes/screens_routes/Screens.dart';

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
                final response = await supabase.auth.signOut();

                // Redirige al usuario a la pantalla de inicio de sesión después de cerrar la sesión
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Cerrar Sesion'),
            )
          ],
        ),
      ),
    );
  }
}
