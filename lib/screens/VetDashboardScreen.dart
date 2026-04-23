import 'package:flutter/material.dart';
import 'package:petixfy/widgets/next_visit_card.dart';
import 'package:petixfy/widgets/vet_status_pill_switch.dart';
import 'package:petixfy/widgets/vet_summary_card.dart';
import 'package:petixfy/widgets/vet_warm_theme.dart';

class VetDashboardScreen extends StatefulWidget {
  const VetDashboardScreen({super.key});

  @override
  State<VetDashboardScreen> createState() => _VetDashboardScreenState();
}

class _VetDashboardScreenState extends State<VetDashboardScreen> {
  bool _availableForEmergencies = true;

  String _todayLabel() {
    final now = DateTime.now();
    const days = ['Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo'];
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    final dayName = days[(now.weekday - 1) % 7];
    return '$dayName, ${now.day} de ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VetWarmTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          children: [
            const Text(
              'Hola, Dr. Sofia',
              style: TextStyle(
                color: VetWarmTheme.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _todayLabel(),
              style: const TextStyle(
                color: VetWarmTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            VetStatusPillSwitch(
              isAvailable: _availableForEmergencies,
              onChanged: (value) => setState(() => _availableForEmergencies = value),
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Expanded(
                  child: VetSummaryCard(
                    title: 'Citas de hoy',
                    value: '6',
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: VetSummaryCard(
                    title: 'Ganancias semana',
                    value: '\$8,420',
                    icon: Icons.attach_money_outlined,
                    tint: VetWarmTheme.sunset,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'Proximas visitas',
              style: TextStyle(
                color: VetWarmTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(
              height: 150,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    NextVisitCard(
                      hour: '09:30',
                      petName: 'Luna',
                      colony: 'Col. Del Valle',
                    ),
                    NextVisitCard(
                      hour: '11:00',
                      petName: 'Rocky',
                      colony: 'Narvarte',
                    ),
                    NextVisitCard(
                      hour: '13:10',
                      petName: 'Milo',
                      colony: 'Roma Norte',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
