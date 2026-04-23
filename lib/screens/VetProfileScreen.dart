import 'package:flutter/material.dart';
import 'package:petixfy/widgets/vet_warm_theme.dart';

class VetProfileScreen extends StatefulWidget {
  const VetProfileScreen({super.key});

  @override
  State<VetProfileScreen> createState() => _VetProfileScreenState();
}

class _VetProfileScreenState extends State<VetProfileScreen> {
  double _coverageRadius = 12;
  bool _serviceCuraciones = true;
  bool _serviceConsultaGeneral = true;
  bool _serviceVacunacion = true;
  bool _serviceLaboratorio = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VetWarmTheme.background,
      appBar: AppBar(
        title: const Text('Configuracion y Logistica'),
        backgroundColor: VetWarmTheme.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: VetWarmTheme.softCardDecoration(color: VetWarmTheme.card),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: VetWarmTheme.sand,
                  child: Icon(Icons.person_outline, color: VetWarmTheme.textPrimary, size: 30),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dra. Sofia Martinez',
                        style: TextStyle(
                          color: VetWarmTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: VetWarmTheme.amber, size: 18),
                          Icon(Icons.star_rounded, color: VetWarmTheme.amber, size: 18),
                          Icon(Icons.star_rounded, color: VetWarmTheme.amber, size: 18),
                          Icon(Icons.star_rounded, color: VetWarmTheme.amber, size: 18),
                          Icon(Icons.star_half_rounded, color: VetWarmTheme.amber, size: 18),
                          SizedBox(width: 6),
                          Text(
                            '4.8',
                            style: TextStyle(
                              color: VetWarmTheme.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: VetWarmTheme.softCardDecoration(color: VetWarmTheme.card),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Radio de cobertura',
                  style: TextStyle(
                    color: VetWarmTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_coverageRadius.toStringAsFixed(0)} km',
                  style: const TextStyle(color: VetWarmTheme.textSecondary),
                ),
                Slider(
                  value: _coverageRadius,
                  min: 1,
                  max: 30,
                  divisions: 29,
                  activeColor: VetWarmTheme.amber,
                  onChanged: (v) => setState(() => _coverageRadius = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: VetWarmTheme.softCardDecoration(color: VetWarmTheme.card),
            child: Column(
              children: [
                SwitchListTile(
                  value: _serviceCuraciones,
                  onChanged: (v) => setState(() => _serviceCuraciones = v),
                  title: const Text('Curaciones'),
                  activeThumbColor: VetWarmTheme.amber,
                ),
                SwitchListTile(
                  value: _serviceConsultaGeneral,
                  onChanged: (v) => setState(() => _serviceConsultaGeneral = v),
                  title: const Text('Consulta General'),
                  activeThumbColor: VetWarmTheme.amber,
                ),
                SwitchListTile(
                  value: _serviceVacunacion,
                  onChanged: (v) => setState(() => _serviceVacunacion = v),
                  title: const Text('Vacunacion'),
                  activeThumbColor: VetWarmTheme.amber,
                ),
                SwitchListTile(
                  value: _serviceLaboratorio,
                  onChanged: (v) => setState(() => _serviceLaboratorio = v),
                  title: const Text('Analisis de laboratorio'),
                  activeThumbColor: VetWarmTheme.amber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
