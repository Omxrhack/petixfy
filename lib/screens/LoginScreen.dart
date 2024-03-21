// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:petixfy/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../routes/screens_routes/Screens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailControler = TextEditingController();

  late final StreamSubscription<AuthState> _authSubscription;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authSubscription = supabase.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session != null) {
        Navigator.of(context).pushReplacementNamed('HomeScreen');
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _emailControler.dispose();
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailControler,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Porfavor ingrese una contraseña';
                }
                return null;
              },
            ),
            ElevatedButton(
                onPressed: () async {
                  try {
                    final email = _emailControler.text.trim();
                    final user = await supabase.auth.getUser(email);

                    if (user != null) {
                      // El usuario ya existe, redirige a la pantalla de inicio
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                      );
                    } else {
                      // El usuario no existe, procede con el inicio de sesión
                      await supabase.auth.signInWithOtp(
                        email: email,
                        emailRedirectTo:
                            'io.supabase.flutterquickstart://login-callback/',
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '¡Correcto! , revisa tu correo para confirmar.',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  } catch (error) {
                    print('Error: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '!Error! , intenta de nuevo. ',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Login')),
          ],
        ),
      ),
    );
  }
}
