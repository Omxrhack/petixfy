import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petixfy/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

    if (!mounted) return;
    if (!success) {
      final message = authProvider.errorMessage ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
      return;
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contrasena'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _login,
                child: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pushNamed(context, 'RegisterScreen'),
                child: const Text('No tienes cuenta? Registrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
