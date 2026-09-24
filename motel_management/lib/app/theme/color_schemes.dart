import 'package:flutter/material.dart';

/// Semantic status colors used throughout the app (paid, unpaid, overdue, maintenance, etc.)
class AppStatusColors {
  AppStatusColors._();

  // Success / Paid / Available
  static const Color success = Color(0xFF1B8755);
  static const Color successContainer = Color(0xFFD1E7DD);
  static const Color onSuccessContainer = Color(0xFF0F5132);

  // Warning / Partially Paid / Pending
  static const Color warning = Color(0xFFC07D00);
  static const Color warningContainer = Color(0xFFFFF3CD);
  static const Color onWarningContainer = Color(0xFF664D03);

  // Danger / Overdue / Inactive
  static const Color danger = Color(0xFFDC3545);
  static const Color dangerContainer = Color(0xFFF8D7DA);
  static const Color onDangerContainer = Color(0xFF842029);

  // Info / Draft / Maintenance
  static const Color info = Color(0xFF0D6EFD);
  static const Color infoContainer = Color(0xFFCFE2FF);
  static const Color onInfoContainer = Color(0xFF084298);

  // Neutral / Left
  static const Color neutral = Color(0xFF6C757D);
  static const Color neutralContainer = Color(0xFFE2E3E5);
  static const Color onNeutralContainer = Color(0xFF41464B);
}

/// Material 3 light color scheme
const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF00639B),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFCEE5FF),
  onPrimaryContainer: Color(0xFF001D33),
  secondary: Color(0xFF51606F),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFD5E4F7),
  onSecondaryContainer: Color(0xFF0E1D2A),
  tertiary: Color(0xFF68587A),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFEFDBFF),
  onTertiaryContainer: Color(0xFF231633),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFF8F9FF),
  onSurface: Color(0xFF191C20),
  surfaceContainerHighest: Color(0xFFE2E2EC),
  onSurfaceVariant: Color(0xFF42474E),
  outline: Color(0xFF72777F),
  outlineVariant: Color(0xFFC2C7CF),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFF2E3035),
  onInverseSurface: Color(0xFFF0F0F7),
  inversePrimary: Color(0xFF96CCFF),
);

/// Material 3 dark color scheme
const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF96CCFF),
  onPrimary: Color(0xFF003353),
  primaryContainer: Color(0xFF004B76),
  onPrimaryContainer: Color(0xFFCEE5FF),
  secondary: Color(0xFFB9C8DA),
  onSecondary: Color(0xFF233240),
  secondaryContainer: Color(0xFF3A4857),
  onSecondaryContainer: Color(0xFFD5E4F7),
  tertiary: Color(0xFFD3BFE6),
  onTertiary: Color(0xFF382A49),
  tertiaryContainer: Color(0xFF4F4061),
  onTertiaryContainer: Color(0xFFEFDBFF),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF111418),
  onSurface: Color(0xFFE1E2E8),
  surfaceContainerHighest: Color(0xFF333538),
  onSurfaceVariant: Color(0xFFC2C7CF),
  outline: Color(0xFF8C9199),
  outlineVariant: Color(0xFF42474E),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFFE1E2E8),
  onInverseSurface: Color(0xFF2E3035),
  inversePrimary: Color(0xFF00639B),
);
