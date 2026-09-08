import 'package:flutter/material.dart';

import 'colors.dart';
import 'spacing.dart';
import 'typography.dart';

/// Maps [EcoColors] tokens onto Material 3 [ThemeData]. Use `AppTheme.light` /
/// `AppTheme.dark`; theme mode is chosen by `AppPreferences` (default: system).
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final background = isDark
        ? EcoColors.darkBackground
        : EcoColors.lightBackground;
    final surface = isDark ? EcoColors.darkSurface : EcoColors.lightSurface;
    final textPrimary = isDark
        ? EcoColors.darkTextPrimary
        : EcoColors.lightTextPrimary;
    final textSecondary = isDark
        ? EcoColors.darkTextSecondary
        : EcoColors.lightTextSecondary;
    final border = isDark ? EcoColors.darkBorder : EcoColors.lightBorder;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: EcoColors.primary,
      onPrimary: EcoColors.onFilled,
      secondary: EcoColors.secondary,
      onSecondary: EcoColors.onFilled,
      error: EcoColors.error,
      onError: EcoColors.onFilled,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: isDark
          ? const Color(0xFF262637)
          : const Color(0xFFF1F3F5),
      outline: border,
    );

    final textTheme = EcoTypography.textTheme(textPrimary, textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EcoRadii.lg),
          side: BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: EcoSpacing.lg,
          vertical: EcoSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EcoRadii.md),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EcoRadii.md),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EcoRadii.md),
          borderSide: const BorderSide(color: EcoColors.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EcoRadii.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      dividerTheme: DividerThemeData(color: border, space: 1, thickness: 1),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
