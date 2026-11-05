import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const emerald = Color(0xFF087D66);
  static const background = Color(0xFFF5F8F6);
  static const charcoal = Color(0xFF17312C);

  static final ColorScheme _scheme = ColorScheme.fromSeed(
    seedColor: emerald,
    brightness: Brightness.light,
    primary: emerald,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: charcoal,
    error: const Color(0xFFC34747),
  );

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: _scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: _scheme.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF6F8F7),
        contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E8E3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _scheme.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _scheme.primary,
        foregroundColor: _scheme.onPrimary,
        extendedTextStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
      ),
    );
  }
}
