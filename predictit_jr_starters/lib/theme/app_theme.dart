import 'package:flutter/material.dart';

/// App-wide Material 3 theme.
///
/// Both light and dark modes are derived from the same brand seed so the app
/// stays recognizable while letting Material choose contrast-safe colors for
/// each brightness.
class AppTheme {
  static const Color _seed = Color(0xFF0B2545);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: false),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(centerTitle: false),
      );
}
