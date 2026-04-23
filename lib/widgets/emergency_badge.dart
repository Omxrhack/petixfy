import 'package:flutter/material.dart';
import 'package:petixfy/widgets/vet_warm_theme.dart';

class EmergencyBadge extends StatelessWidget {
  const EmergencyBadge({
    super.key,
    required this.urgency,
  });

  final String urgency;

  @override
  Widget build(BuildContext context) {
    final color = switch (urgency.toLowerCase()) {
      'alta' => VetWarmTheme.sunset,
      'media' => VetWarmTheme.amber,
      _ => VetWarmTheme.textSecondary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Urgencia: $urgency',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
