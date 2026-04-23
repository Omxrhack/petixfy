import 'package:flutter/material.dart';
import 'package:petixfy/widgets/vet_warm_theme.dart';

class VetSummaryCard extends StatelessWidget {
  const VetSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.tint,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final color = tint ?? VetWarmTheme.amber;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: VetWarmTheme.softCardDecoration(color: VetWarmTheme.card),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: VetWarmTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: VetWarmTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
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
