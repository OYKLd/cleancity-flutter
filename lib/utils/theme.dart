import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Thème centralisé de CleanCity (Material 3, palette de verts sauge, Poppins).
/// Tous les écrans utilisent ce thème : ne pas coder de couleurs en dur
/// dans les écrans, passer par Theme.of(context).colorScheme.
class AppTheme {
  AppTheme._();

  // Sage green palette, from lightest to darkest.
  static const Color vertPale = Color(0xFFD9E5D7);
  static const Color vertMenthe = Color(0xFFBFCFBB);
  static const Color vertSauge = Color(0xFF8EA58C);
  static const Color vertMousse = Color(0xFF738A6E);
  static const Color vertSapin = Color(0xFF344C3D);

  // Neutral tones with a slight green tint, used for text and surfaces.
  static const Color encre = Color(0xFF1B231D);
  static const Color encreDouce = Color(0xFF4F5B52);
  static const Color fond = Color(0xFFFBFCFA);

  /// Kept for code written against the first version of the theme.
  static const Color vertPrincipal = vertSapin;

  /// Bundled in assets/fonts so the app never depends on the network for text.
  static const String police = 'Poppins';

  static const double rayon = 14;

  static ThemeData get clair {
    // Dark evergreen as primary: strong contrast on light surfaces (~9:1),
    // while the lighter shades are used for containers and highlights.
    final colorScheme = ColorScheme.fromSeed(seedColor: vertSapin).copyWith(
      primary: vertSapin,
      onPrimary: Colors.white,
      primaryContainer: vertMenthe,
      onPrimaryContainer: vertSapin,
      secondary: vertMousse,
      onSecondary: Colors.white,
      secondaryContainer: vertPale,
      onSecondaryContainer: vertSapin,
      tertiary: vertSauge,
      onTertiary: Colors.white,
      tertiaryContainer: vertPale,
      onTertiaryContainer: vertSapin,
      surface: fond,
      onSurface: encre,
      onSurfaceVariant: encreDouce,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF3F6F1),
      surfaceContainer: const Color(0xFFEDF2EB),
      surfaceContainerHigh: const Color(0xFFE6ECE4),
      surfaceContainerHighest: vertPale,
      outline: vertMousse,
      outlineVariant: vertMenthe,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: police,
    );
    final textTheme = base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: encre,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: encre,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: encre,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: encre,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(color: encre),
      bodySmall: base.textTheme.bodySmall?.copyWith(color: encreDouce),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );

    final formeBouton = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(rayon),
    );
    const tailleBouton = Size.fromHeight(52);

    OutlineInputBorder bordureChamp(Color couleur, [double largeur = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(rayon),
        borderSide: BorderSide(color: couleur, width: largeur),
      );
    }

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: vertSapin,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: vertSapin,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vertSapin,
          foregroundColor: Colors.white,
          minimumSize: tailleBouton,
          elevation: 0,
          shape: formeBouton,
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: vertSapin,
          foregroundColor: Colors.white,
          minimumSize: tailleBouton,
          shape: formeBouton,
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: vertSapin,
          minimumSize: tailleBouton,
          side: const BorderSide(color: vertMousse),
          shape: formeBouton,
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: vertSapin,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: bordureChamp(vertMenthe),
        enabledBorder: bordureChamp(vertMenthe),
        focusedBorder: bordureChamp(vertSapin, 1.6),
        errorBorder: bordureChamp(colorScheme.error),
        focusedErrorBorder: bordureChamp(colorScheme.error, 1.6),
        disabledBorder: bordureChamp(colorScheme.surfaceContainerHigh),
        labelStyle: TextStyle(color: encreDouce),
        floatingLabelStyle: const TextStyle(color: vertSapin),
        hintStyle: TextStyle(color: encreDouce.withValues(alpha: 0.7)),
        helperStyle: textTheme.bodySmall,
        prefixIconColor: vertMousse,
        suffixIconColor: vertMousse,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLowest,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: vertPale),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: vertSapin,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        indicatorColor: vertMenthe,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? vertSapin : encreDouce,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? vertSapin : encreDouce);
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        selectedColor: vertMenthe,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: encre,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(
        color: vertPale,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: vertSapin,
      ),
    );
  }
}
