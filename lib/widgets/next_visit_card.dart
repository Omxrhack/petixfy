import 'package:flutter/material.dart';
import 'package:petixfy/widgets/vet_warm_theme.dart';

class NextVisitCard extends StatelessWidget {
  const NextVisitCard({
    super.key,
    required this.hour,
    required this.petName,
    required this.colony,
  });

  final String hour;
  final String petName;
  final String colony;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 12),
      decoration: VetWarmTheme.softCardDecoration(color: VetWarmTheme.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hour,
            style: const TextStyle(
              color: VetWarmTheme.sunset,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            petName,
            style: const TextStyle(
              color: VetWarmTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            colony,
            style: const TextStyle(
              color: VetWarmTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
