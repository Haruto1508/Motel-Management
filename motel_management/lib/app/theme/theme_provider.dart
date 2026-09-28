import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_management/core/storage/preferences_service.dart';
import 'package:rental_management/features/auth/presentation/providers/auth_providers.dart';

/// StateNotifier that manages and persists application theme mode.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final PreferencesService _preferencesService;

  ThemeModeNotifier(this._preferencesService) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final savedMode = _preferencesService.getThemeMode();
    if (savedMode != null) {
      switch (savedMode) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'dark':
          state = ThemeMode.dark;
          break;
        case 'system':
        default:
          state = ThemeMode.system;
          break;
      }
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final modeString = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _preferencesService.setThemeMode(modeString);
  }

  /// Toggles between light and dark theme mode.
  /// If current mode is system, resolves active brightness first.
  Future<void> toggleTheme(BuildContext context) async {
    final isDark = switch (state) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };

    await setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }
}

/// Provider exposing current ThemeMode and methods to update it.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final preferences = ref.watch(preferencesServiceProvider);
  return ThemeModeNotifier(preferences);
});
