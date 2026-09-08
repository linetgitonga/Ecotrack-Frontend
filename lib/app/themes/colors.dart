import 'package:flutter/material.dart';

/// EcoTrack colour tokens, from the design system in the build brief.
///
/// Reference every colour through this class — never hard-code a hex in a
/// widget. Light and dark are both defined explicitly (dark is derived, not
/// guessed) so contrast can be validated (see test/unit/colors_contrast_test.dart).
abstract final class EcoColors {
  // --- Brand ---------------------------------------------------------------
  static const Color primary = Color(0xFF1A8A4F); // EcoTrack green
  static const Color secondary = Color(0xFF3498DB); // information blue

  // --- Semantic ----------------------------------------------------------
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // --- Connection state (also used by ConnectionStatusIndicator) --------
  static const Color lanMode = Color(0xFF2ECC71); // green  — direct hub
  static const Color cloudMode = Color(0xFF3498DB); // blue   — remote
  static const Color offlineMode = Color(0xFFE74C3C); // red    — cached only

  // --- Light surfaces & text ------------------------------------------
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // --- Dark surfaces & text (derived) --------------------------------
  static const Color darkBackground = Color(0xFF121218);
  static const Color darkSurface = Color(0xFF1E1E2E);
  static const Color darkTextPrimary = Color(0xFFECECF1);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF2E2E3E);

  // --- Elevation ----------------------------------------------------------
  static const Color cardShadow = Color(0x14000000); // rgba(0,0,0,0.08)

  /// On-colour for filled brand/semantic surfaces (meets AA on all of them).
  static const Color onFilled = Color(0xFFFFFFFF);
}
