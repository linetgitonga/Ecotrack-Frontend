import 'package:flutter/material.dart';

/// EcoTrack type scale. Built on the platform system font with an explicit
/// fallback stack so text renders consistently on Android, iOS and web.
abstract final class EcoTypography {
  static const String _fontFamily = 'Roboto';
  static const List<String> _fallback = <String>[
    'SF Pro Text',
    'Segoe UI',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  static TextTheme textTheme(Color primary, Color secondary) {
    TextStyle base(
      double size,
      FontWeight weight, {
      double? height,
      Color? color,
    }) {
      return TextStyle(
        fontFamily: _fontFamily,
        fontFamilyFallback: _fallback,
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color ?? primary,
      );
    }

    return TextTheme(
      displaySmall: base(32, FontWeight.w700, height: 1.2),
      headlineMedium: base(24, FontWeight.w700, height: 1.25),
      headlineSmall: base(20, FontWeight.w600, height: 1.3),
      titleLarge: base(18, FontWeight.w600, height: 1.3),
      titleMedium: base(16, FontWeight.w600, height: 1.4),
      bodyLarge: base(16, FontWeight.w400, height: 1.5),
      bodyMedium: base(14, FontWeight.w400, height: 1.5),
      bodySmall: base(12, FontWeight.w400, height: 1.4, color: secondary),
      labelLarge: base(14, FontWeight.w600, height: 1.2),
      labelMedium: base(12, FontWeight.w500, height: 1.2, color: secondary),
    );
  }
}
