import 'package:flutter/material.dart';
import 'package:petixfy/widgets/vet_warm_theme.dart';

class VetAppointmentCard extends StatelessWidget {
  const VetAppointmentCard({
    super.key,
    required this.hour,
    required this.petName,
    required this.ownerName,
    required this.colony,
    required this.serviceType,
    required this.isUrgency,
    required this.onRouteTap,
  });

  final String hour;
  final String petName;
  final String ownerName;
  final String colony;
  final String serviceType;
  final bool isUrgency;
  final VoidCallback onRouteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: VetWarmTheme.softCardDecoration(color: VetWarmTheme.card),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: VetWarmTheme.sand,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              hour,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: VetWarmTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  petName,
                  style: const TextStyle(
                    color: VetWarmTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ownerName,
                  style: const TextStyle(
                    color: VetWarmTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  colony,
                  style: const TextStyle(
                    color: VetWarmTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Chip(
                      label: Text(serviceType),
                      backgroundColor: VetWarmTheme.sand,
                      side: BorderSide.none,
                      labelStyle: const TextStyle(
                        color: VetWarmTheme.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                    if (isUrgency)
                      Chip(
                        label: const Text('Urgencia'),
                        backgroundColor: VetWarmTheme.sunset.withValues(alpha: 0.18),
                        side: BorderSide.none,
                        labelStyle: const TextStyle(
                          color: VetWarmTheme.sunset,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: onRouteTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VetWarmTheme.amber,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Ver Ruta'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
