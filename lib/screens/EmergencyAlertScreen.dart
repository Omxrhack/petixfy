import 'package:flutter/material.dart';
import 'package:petixfy/widgets/emergency_badge.dart';
import 'package:petixfy/widgets/vet_warm_theme.dart';

class EmergencyAlertScreen extends StatelessWidget {
  const EmergencyAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E7),
      appBar: AppBar(
        title: const Text('Alerta de Emergencia'),
        backgroundColor: const Color(0xFFFFF3E7),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: VetWarmTheme.softCardDecoration(
                  color: const Color(0xFFFFB562),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Urgencia 24/7 entrante',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Paciente: Kira\nDistancia: 2.1 km',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const EmergencyBadge(urgency: 'Alta'),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: VetWarmTheme.softCardDecoration(color: VetWarmTheme.card),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen Triage IA',
                      style: TextStyle(
                        color: VetWarmTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '- Presenta dificultad respiratoria\n- No ha comido en 24h\n- Decaimiento notable',
                      style: TextStyle(
                        color: VetWarmTheme.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VetWarmTheme.sunset,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 58),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Aceptar Emergencia',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: VetWarmTheme.textPrimary,
                    minimumSize: const Size(double.infinity, 58),
                    side: const BorderSide(color: VetWarmTheme.sand),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Rechazar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
