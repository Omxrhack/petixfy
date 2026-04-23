import 'package:flutter/material.dart';
import 'package:petixfy/widgets/vet_warm_theme.dart';

class PatientRecordScreen extends StatelessWidget {
  const PatientRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VetWarmTheme.background,
      appBar: AppBar(
        title: const Text('Expediente del Paciente'),
        backgroundColor: VetWarmTheme.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        children: [
          Container(
            decoration: VetWarmTheme.softCardDecoration(color: VetWarmTheme.card),
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: VetWarmTheme.sand,
                  ),
                  child: const Icon(
                    Icons.pets_outlined,
                    size: 40,
                    color: VetWarmTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Luna',
                        style: TextStyle(
                          color: VetWarmTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text('Edad: 3 anos', style: TextStyle(color: VetWarmTheme.textSecondary)),
                      Text('Peso: 12.4 kg', style: TextStyle(color: VetWarmTheme.textSecondary)),
                      Text('Dueno: Daniela Perez', style: TextStyle(color: VetWarmTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: VetWarmTheme.softCardDecoration(color: VetWarmTheme.softDanger),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alergias / Notas Medicas',
                  style: TextStyle(
                    color: VetWarmTheme.dangerText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Alergia al pollo. Antecedente de convulsiones en episodios de estres intenso.',
                  style: TextStyle(
                    color: VetWarmTheme.dangerText,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: VetWarmTheme.softCardDecoration(color: VetWarmTheme.card),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Temperamento',
                  style: TextStyle(
                    color: VetWarmTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text('Nervioso'),
                      backgroundColor: VetWarmTheme.sand,
                      side: BorderSide.none,
                    ),
                    Chip(
                      label: Text('Requiere bozal'),
                      backgroundColor: VetWarmTheme.softDanger,
                      side: BorderSide.none,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
