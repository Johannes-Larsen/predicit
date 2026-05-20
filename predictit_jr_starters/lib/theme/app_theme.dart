import 'package:flutter/material.dart';

/// App-wide theme. Students extend this in A10.
class AppTheme {
  AppTheme._();

  static const Color _navy = Color(0xFF0B2545);
  static const Color _teal = Color(0xFF13A89E);
  static const Color _mint = Color(0xFFB8F2E6);
  static const Color _coral = Color(0xFFEF8354);

  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: _navy,
      primary: _navy,
      secondary: _teal,
      tertiary: _coral,
      surfaceContainerHighest: _mint,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      cardTheme: CardThemeData(
        elevation: 1,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
      ),
    );
  }

  // A10 task: define `dark` theme here.
}
