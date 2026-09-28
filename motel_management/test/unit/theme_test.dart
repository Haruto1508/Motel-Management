import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rental_management/app/theme/theme_provider.dart';
import 'package:rental_management/core/storage/preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeModeNotifier Tests', () {
    test('initializes with ThemeMode.system by default if no saved preference', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final preferencesService = PreferencesService(prefs);

      final notifier = ThemeModeNotifier(preferencesService);

      expect(notifier.state, equals(ThemeMode.system));
    });

    test('initializes with saved preference when available', () async {
      SharedPreferences.setMockInitialValues({
        'app_theme_mode': 'dark',
      });
      final prefs = await SharedPreferences.getInstance();
      final preferencesService = PreferencesService(prefs);

      final notifier = ThemeModeNotifier(preferencesService);

      expect(notifier.state, equals(ThemeMode.dark));
    });

    test('setThemeMode updates state and persists to preferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final preferencesService = PreferencesService(prefs);

      final notifier = ThemeModeNotifier(preferencesService);

      await notifier.setThemeMode(ThemeMode.light);
      expect(notifier.state, equals(ThemeMode.light));
      expect(preferencesService.getThemeMode(), equals('light'));

      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.state, equals(ThemeMode.dark));
      expect(preferencesService.getThemeMode(), equals('dark'));

      await notifier.setThemeMode(ThemeMode.system);
      expect(notifier.state, equals(ThemeMode.system));
      expect(preferencesService.getThemeMode(), equals('system'));
    });
  });
}
