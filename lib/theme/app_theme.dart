import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Tema global de Petixfy
/// Estilo: Cálido y amigable (mascota-friendly)
class AppTheme {
  AppTheme._();

  // ============================================
  // TEMA CLARO
  // ============================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: AppColors.lightColorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: _textTheme(AppColors.textPrimary),
      appBarTheme: _appBarTheme(isLight: true),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(isLight: true),
      cardTheme: _cardTheme(isLight: true),
      floatingActionButtonTheme: _fabTheme(),
      bottomNavigationBarTheme: _bottomNavTheme(isLight: true),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
      ),
      snackBarTheme: _snackBarTheme(),
      dialogTheme: _dialogTheme(isLight: true),
      bottomSheetTheme: _bottomSheetTheme(isLight: true),
    );
  }

  // ============================================
  // TEMA OSCURO
  // ============================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: AppColors.darkColorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: _textTheme(AppColors.textOnDark),
      appBarTheme: _appBarTheme(isLight: false),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(isLight: false),
      cardTheme: _cardTheme(isLight: false),
      floatingActionButtonTheme: _fabTheme(),
      bottomNavigationBarTheme: _bottomNavTheme(isLight: false),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
      ),
      snackBarTheme: _snackBarTheme(),
      dialogTheme: _dialogTheme(isLight: false),
      bottomSheetTheme: _bottomSheetTheme(isLight: false),
    );
  }

  // ============================================
  // TIPOGRAFÍA (Poppins mejorada)
  // ============================================
  static TextTheme _textTheme(Color textColor) {
    return GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.15,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.15,
        letterSpacing: -0.25,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.2,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.2,
        letterSpacing: 0.2,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.25,
        letterSpacing: 0.15,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
        letterSpacing: 0.1,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
        letterSpacing: 0.15,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.5,
        letterSpacing: 0.15,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.5,
        letterSpacing: 0.1,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textColor.withOpacity(0.8),
        height: 1.5,
        letterSpacing: 0.1,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textColor.withOpacity(0.8),
        height: 1.4,
        letterSpacing: 0.1,
      ),
    );
  }

  // ============================================
  // APP BAR
  // ============================================
  static AppBarTheme _appBarTheme({required bool isLight}) {
    return AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
      foregroundColor: isLight ? AppColors.textPrimary : AppColors.textOnDark,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isLight ? AppColors.textPrimary : AppColors.textOnDark,
      ),
      iconTheme: IconThemeData(
        color: isLight ? AppColors.textPrimary : AppColors.textOnDark,
      ),
    );
  }

  // ============================================
  // BOTONES
  // ============================================
  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 2,
        shadowColor: AppColors.shadowLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================
  // CAMPOS DE TEXTO
  // ============================================
  static InputDecorationTheme _inputDecorationTheme({required bool isLight}) {
    final borderColor = isLight ? AppColors.borderLight : AppColors.borderDark;
    final fillColor = isLight ? AppColors.surfaceLight : AppColors.surfaceDark;
    final textColor = isLight ? AppColors.textPrimary : AppColors.textOnDark;
    final hintColor = isLight ? AppColors.textTertiary : AppColors.textOnDarkSecondary;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      hintStyle: GoogleFonts.poppins(color: hintColor),
      labelStyle: GoogleFonts.poppins(color: textColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }

  // ============================================
  // TARJETAS
  // ============================================
  static CardThemeData _cardTheme({required bool isLight}) {
    return CardThemeData(
      color: isLight ? AppColors.cardLight : AppColors.cardDark,
      elevation: 2,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    );
  }

  // ============================================
  // FAB
  // ============================================
  static FloatingActionButtonThemeData _fabTheme() {
    return const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 4,
      shape: CircleBorder(),
    );
  }

  // ============================================
  // BOTTOM NAV
  // ============================================
  static BottomNavigationBarThemeData _bottomNavTheme({required bool isLight}) {
    return BottomNavigationBarThemeData(
      backgroundColor: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: isLight ? AppColors.textSecondary : AppColors.textOnDarkSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // ============================================
  // SNACKBAR
  // ============================================
  static SnackBarThemeData _snackBarTheme() {
    return SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: GoogleFonts.poppins(
        color: AppColors.textOnPrimary,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    );
  }

  // ============================================
  // DIÁLOGOS
  // ============================================
  static DialogThemeData _dialogTheme({required bool isLight}) {
    return DialogThemeData(
      backgroundColor: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isLight ? AppColors.textPrimary : AppColors.textOnDark,
      ),
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: isLight ? AppColors.textSecondary : AppColors.textOnDarkSecondary,
      ),
    );
  }

  // ============================================
  // BOTTOM SHEET
  // ============================================
  static BottomSheetThemeData _bottomSheetTheme({required bool isLight}) {
    return BottomSheetThemeData(
      backgroundColor: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      dragHandleColor: isLight ? AppColors.borderLight : AppColors.borderDark,
      dragHandleSize: const Size(40, 4),
    );
  }
}
