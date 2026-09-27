import 'package:flutter/material.dart';

/// Thème centralisé de CleanCity (Material 3, couleur principale verte).
/// Tous les écrans utilisent ce thème : ne pas coder de couleurs en dur
/// dans les écrans, passer par Theme.of(context).colorScheme.
class AppTheme {
  static const Color vertPrincipal = Color(0xFF2E7D32);

  /// Bundled in assets/fonts so the app never depends on the network for text.
  static const String police = 'Poppins';

  static ThemeData get clair {
    final colorScheme = ColorScheme.fromSeed(seedColor: vertPrincipal);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: police,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: vertPrincipal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: vertPrincipal,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vertPrincipal,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
