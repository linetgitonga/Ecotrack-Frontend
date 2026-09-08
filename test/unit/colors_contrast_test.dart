import 'dart:math';

import 'package:ecotrack/app/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.1 relative luminance.
double _luminance(Color c) {
  double channel(double v) {
    v = v / 255.0;
    return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel((c.r * 255)) +
      0.7152 * channel((c.g * 255)) +
      0.0722 * channel((c.b * 255));
}

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = max(la, lb);
  final lo = min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  // AA: 4.5:1 for body text, 3:1 for large text / non-text UI.
  const bodyMin = 4.5;
  const largeMin = 3.0;

  void check(String name, Color fg, Color bg, double min) {
    final ratio = _contrast(fg, bg);
    expect(
      ratio,
      greaterThanOrEqualTo(min),
      reason: '$name: ${ratio.toStringAsFixed(2)}:1 (need $min:1)',
    );
  }

  group('light theme', () {
    test('primary text on surfaces', () {
      check(
        'textPrimary/background',
        EcoColors.lightTextPrimary,
        EcoColors.lightBackground,
        bodyMin,
      );
      check(
        'textPrimary/surface',
        EcoColors.lightTextPrimary,
        EcoColors.lightSurface,
        bodyMin,
      );
    });
    test('secondary text on surface', () {
      check(
        'textSecondary/surface',
        EcoColors.lightTextSecondary,
        EcoColors.lightSurface,
        bodyMin,
      );
    });
    test('on-colour for filled brand/semantic surfaces (large text / UI)', () {
      check(
        'onFilled/primary',
        EcoColors.onFilled,
        EcoColors.primary,
        largeMin,
      );
      check(
        'onFilled/secondary',
        EcoColors.onFilled,
        EcoColors.secondary,
        largeMin,
      );
      check('onFilled/error', EcoColors.onFilled, EcoColors.error, largeMin);
      // Amber warning uses dark text, not white.
      check(
        'onWarning/warning',
        EcoColors.onWarning,
        EcoColors.warning,
        bodyMin,
      );
    });
    test('brand green as an accent on white (UI components)', () {
      check(
        'primary/surface',
        EcoColors.primary,
        EcoColors.lightSurface,
        largeMin,
      );
    });
  });

  group('dark theme', () {
    test('primary text on surfaces', () {
      check(
        'darkTextPrimary/background',
        EcoColors.darkTextPrimary,
        EcoColors.darkBackground,
        bodyMin,
      );
      check(
        'darkTextPrimary/surface',
        EcoColors.darkTextPrimary,
        EcoColors.darkSurface,
        bodyMin,
      );
    });
    test('secondary text on surface', () {
      check(
        'darkTextSecondary/surface',
        EcoColors.darkTextSecondary,
        EcoColors.darkSurface,
        bodyMin,
      );
    });
  });
}
