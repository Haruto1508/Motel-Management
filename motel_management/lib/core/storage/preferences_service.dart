import 'package:shared_preferences/shared_preferences.dart';
import 'package:rental_management/core/constants/app_constants.dart';

/// SharedPreferences wrapper for non-sensitive settings and lightweight offline caching.
class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  // Theme Mode
  String? getThemeMode() => _prefs.getString(AppConstants.keyThemeMode);
  Future<bool> setThemeMode(String mode) =>
      _prefs.setString(AppConstants.keyThemeMode, mode);

  // Generic Cache
  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();
}
