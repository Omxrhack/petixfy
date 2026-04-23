import 'package:flutter/material.dart';
import 'package:petixfy/widgets/vet_warm_theme.dart';

class VetStatusPillSwitch extends StatelessWidget {
  const VetStatusPillSwitch({
    super.key,
    required this.isAvailable,
    required this.onChanged,
  });

  final bool isAvailable;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = isAvailable ? 'Disponible para Emergencias' : 'Fuera de turno';
    final color = isAvailable ? VetWarmTheme.amber : VetWarmTheme.textSecondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: VetWarmTheme.softCardDecoration(color: VetWarmTheme.card),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: isAvailable,
              onChanged: onChanged,
              activeThumbColor: VetWarmTheme.amber,
              inactiveTrackColor: VetWarmTheme.sand,
            ),
          ),
        ],
      ),
    );
  }
}
