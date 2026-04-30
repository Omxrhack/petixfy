import 'package:flutter/material.dart';

/// Paleta de colores unificada para Petixfy
/// Estilo: Cálido y amigable (mascota-friendly)
class AppColors {
  AppColors._();

  // ============================================
  // COLORES PRIMARIOS (Teal más cálido)
  // ============================================
  static const Color primary = Color(0xFF00B8A9);
  static const Color primaryLight = Color(0xFF7FD3C1);
  static const Color primaryDark = Color(0xFF008F82);
  static const Color primarySurface = Color(0xFFE0F7F5);
  static const Color primaryMedium = Color(0xFF4DC4B5);

  // ============================================
  // COLORES SECUNDARIOS (Crema/Cálido)
  // ============================================
  static const Color secondary = Color(0xFFFFF5E6);
  static const Color secondaryDark = Color(0xFFFFE4C4);
  static const Color accent = Color(0xFFF5A623);
  static const Color accentLight = Color(0xFFFFD180);
  
  // Colores pastel para ilustraciones
  static const Color peach = Color(0xFFFFDDD2);
  static const Color lavender = Color(0xFFE7D4F5);
  static const Color mint = Color(0xFFD4F5E7);

  // ============================================
  // FONDOS
  // ============================================
  static const Color backgroundLight = Color(0xFFFAFAF8);
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2D2D2D);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF3D3D3D);

  // ============================================
  // TEXTOS (mejorado contraste)
  // ============================================
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF5A5A5A);
  static const Color textTertiary = Color(0xFF8E8E8E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFF5F5F5);
  static const Color textOnDarkSecondary = Color(0xFFB0B0B0);

  // ============================================
  // ESTADOS / FEEDBACK
  // ============================================
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ============================================
  // COLORES VETERINARIOS (Warm Theme)
  // ============================================
  static const Color vetBackground = Color(0xFFFFF8F0);
  static const Color vetCard = Color(0xFFFFFFFF);
  static const Color vetAmber = Color(0xFFE8A855);
  static const Color vetSunset = Color(0xFFE87B55);
  static const Color vetSand = Color(0xFFD4C4A8);
  static const Color vetSoftDanger = Color(0xFFE85555);

  // ============================================
  // BORDES Y DIVISORES
  // ============================================
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);
  static const Color dividerLight = Color(0xFFEEEEEE);
  static const Color dividerDark = Color(0xFF3D3D3D);

  // ============================================
  // SOMBRAS
  // ============================================
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);

  // ============================================
  // GRADIENTES
  // ============================================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryDark],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, Color(0xFFFFE8CC)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryLight, primary],
  );

  // ============================================
  // COLOR SCHEME PARA MATERIAL 3
  // ============================================
  static ColorScheme get lightColorScheme => ColorScheme.light(
        primary: primary,
        primaryContainer: primarySurface,
        secondary: accent,
        secondaryContainer: accentLight,
        surface: surfaceLight,
        error: error,
        onPrimary: textOnPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onError: textOnPrimary,
      );

  static ColorScheme get darkColorScheme => ColorScheme.dark(
        primary: primaryLight,
        primaryContainer: primaryDark,
        secondary: accent,
        secondaryContainer: Color(0xFF8B5A00),
        surface: surfaceDark,
        error: Color(0xFFCF6679),
        onPrimary: textPrimary,
        onSecondary: textOnDark,
        onSurface: textOnDark,
        onError: textPrimary,
      );
}
