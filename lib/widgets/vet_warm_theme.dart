import 'package:flutter/material.dart';

class VetWarmTheme {
  VetWarmTheme._();

  static const Color background = Color(0xFFFFF8F1);
  static const Color card = Color(0xFFFFFDF9);
  static const Color textPrimary = Color(0xFF3B2A22);
  static const Color textSecondary = Color(0xFF7D6557);
  static const Color amber = Color(0xFFF2A14A);
  static const Color sunset = Color(0xFFE97D5F);
  static const Color sand = Color(0xFFF4E6D7);
  static const Color softDanger = Color(0xFFFFE4DB);
  static const Color dangerText = Color(0xFF9A3D2F);

  static BoxDecoration softCardDecoration({
    Color? color,
    Color shadowColor = const Color(0x33000000),
  }) {
    return BoxDecoration(
      color: color ?? card,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.08),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
