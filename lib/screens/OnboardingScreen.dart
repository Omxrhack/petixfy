import 'package:flutter/material.dart';
import 'package:petixfy/services/auth_api.dart';
import 'package:petixfy/services/auth_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _role = 'client';
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await AuthApi.onboarding(
        role: _role,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      await AuthState.save(newOnboardingCompleted: true);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, 'HomeScreen');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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
      appBar: AppBar(title: const Text('Completa tu perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('¿Quién eres en Vetgo?'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _role,
              items: const [
                DropdownMenuItem(value: 'client', child: Text('Cliente / dueño')),
                DropdownMenuItem(value: 'vet', child: Text('Veterinario')),
              ],
              onChanged: (value) => setState(() => _role = value ?? 'client'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),
            const SizedBox(height: 20),
            if (_role == 'vet')
              const Text(
                'Siguiente paso sugerido: agregar cédula profesional en un módulo extendido.',
                style: TextStyle(fontSize: 12),
              )
            else
              const Text(
                'Siguiente paso sugerido: registrar tu primera mascota en el módulo Pets.',
                style: TextStyle(fontSize: 12),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Finalizar onboarding'),
            ),
          ],
        ),
      ),
    );
  }
}
