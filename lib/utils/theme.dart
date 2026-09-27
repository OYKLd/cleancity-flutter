import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralised CleanCity theme (Material 3, sage green palette, Poppins).
/// Screens must not hardcode colours: use Theme.of(context).colorScheme.
class AppTheme {
  AppTheme._();

  // Sage green palette, from lightest to darkest.
  static const Color sageHint = Color(0xFFD9E5D7);
  static const Color mint = Color(0xFFBFCFBB);
  static const Color sage = Color(0xFF8EA58C);
  static const Color moss = Color(0xFF738A6E);
  static const Color evergreen = Color(0xFF344C3D);

  // Neutral tones with a slight green tint, used for text and surfaces.
  static const Color ink = Color(0xFF1B231D);
  static const Color inkMuted = Color(0xFF4F5B52);
  static const Color background = Color(0xFFFBFCFA);

  /// Bundled in assets/fonts so the app never depends on the network for text.
  static const String fontFamily = 'Poppins';

  static const double radius = 18;

  static ThemeData get light {
    // Dark evergreen as primary: strong contrast on light surfaces (~9:1),
    // while the lighter shades are used for containers and highlights.
    final colorScheme = ColorScheme.fromSeed(seedColor: evergreen).copyWith(
      primary: evergreen,
      onPrimary: Colors.white,
      primaryContainer: mint,
      onPrimaryContainer: evergreen,
      secondary: moss,
      onSecondary: Colors.white,
      secondaryContainer: sageHint,
      onSecondaryContainer: evergreen,
      tertiary: sage,
      onTertiary: Colors.white,
      tertiaryContainer: sageHint,
      onTertiaryContainer: evergreen,
      surface: background,
      onSurface: ink,
      onSurfaceVariant: inkMuted,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF3F6F1),
      surfaceContainer: const Color(0xFFEDF2EB),
      surfaceContainerHigh: const Color(0xFFE6ECE4),
      surfaceContainerHighest: sageHint,
      outline: moss,
      outlineVariant: mint,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
    );
    // Poppins runs large, so every size sits one or two points under the
    // Material 3 defaults, body text first (16/14/12 -> 15/13/11.5).
    final textTheme = base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleSmall: base.textTheme.titleSmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(fontSize: 15, color: ink),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        fontSize: 13,
        color: ink,
      ),
      bodySmall: base.textTheme.bodySmall?.copyWith(
        fontSize: 11.5,
        color: inkMuted,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
      ),
    );

    const buttonShape = StadiumBorder();
    const buttonSize = Size.fromHeight(54);

    OutlineInputBorder fieldBorder(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: evergreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontSize: 17,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: evergreen,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: evergreen,
          foregroundColor: Colors.white,
          minimumSize: buttonSize,
          elevation: 0,
          shape: buttonShape,
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 14),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: evergreen,
          foregroundColor: Colors.white,
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: evergreen,
          minimumSize: buttonSize,
          side: const BorderSide(color: moss),
          shape: buttonShape,
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: evergreen,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: fieldBorder(sageHint),
        enabledBorder: fieldBorder(sageHint),
        focusedBorder: fieldBorder(evergreen, 1.6),
        errorBorder: fieldBorder(colorScheme.error),
        focusedErrorBorder: fieldBorder(colorScheme.error, 1.6),
        disabledBorder: fieldBorder(colorScheme.surfaceContainerHigh),
        labelStyle: const TextStyle(color: inkMuted),
        floatingLabelStyle: const TextStyle(color: evergreen),
        hintStyle: TextStyle(color: inkMuted.withValues(alpha: 0.7)),
        helperStyle: textTheme.bodySmall,
        prefixIconColor: evergreen,
        suffixIconColor: moss,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLowest,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: sageHint),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: evergreen,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        indicatorColor: mint,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? evergreen : inkMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? evergreen : inkMuted);
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        selectedColor: mint,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLowest,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(
        color: sageHint,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: evergreen,
      ),
    );
  }
}
