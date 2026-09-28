import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rental_management/core/constants/app_constants.dart';
import 'package:rental_management/core/storage/preferences_service.dart';

/// Secure token & sensitive credential storage service.
/// Uses FlutterSecureStorage with automatic PreferencesService fallback for Web and offline reliability.
class SecureStorageService {
  final FlutterSecureStorage _storage;
  final PreferencesService? preferences;

  SecureStorageService({
    FlutterSecureStorage? storage,
    this.preferences,
  })  : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
              webOptions: WebOptions(
                dbName: 'motel_secure_storage',
                publicKey: 'motel_secure_storage_pub',
              ),
            );

  Future<void> saveAccessToken(String token) async {
    if (!kIsWeb) {
      try {
        await _storage.write(key: AppConstants.keyAccessToken, value: token);
      } catch (e) {
        debugPrint('⚠️ [SecureStorage] Write access token fallback: $e');
      }
    }
    await preferences?.setString(AppConstants.keyAccessToken, token);
  }

  Future<String?> getAccessToken() async {
    if (!kIsWeb) {
      try {
        final token = await _storage.read(key: AppConstants.keyAccessToken);
        if (token != null && token.isNotEmpty) return token;
      } catch (e) {
        debugPrint('⚠️ [SecureStorage] Read access token fallback: $e');
      }
    }
    return preferences?.getString(AppConstants.keyAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    if (!kIsWeb) {
      try {
        await _storage.write(key: AppConstants.keyRefreshToken, value: token);
      } catch (e) {
        debugPrint('⚠️ [SecureStorage] Write refresh token fallback: $e');
      }
    }
    await preferences?.setString(AppConstants.keyRefreshToken, token);
  }

  Future<String?> getRefreshToken() async {
    if (!kIsWeb) {
      try {
        final token = await _storage.read(key: AppConstants.keyRefreshToken);
        if (token != null && token.isNotEmpty) return token;
      } catch (e) {
        debugPrint('⚠️ [SecureStorage] Read refresh token fallback: $e');
      }
    }
    return preferences?.getString(AppConstants.keyRefreshToken);
  }

  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  Future<void> clearAuthTokens() async {
    if (!kIsWeb) {
      try {
        await Future.wait([
          _storage.delete(key: AppConstants.keyAccessToken),
          _storage.delete(key: AppConstants.keyRefreshToken),
          _storage.delete(key: AppConstants.keyUserId),
          _storage.delete(key: AppConstants.keyUserEmail),
          _storage.delete(key: AppConstants.keyUserRole),
        ]);
      } catch (e) {
        debugPrint('⚠️ [SecureStorage] Clear tokens fallback: $e');
      }
    }
    await Future.wait([
      preferences?.remove(AppConstants.keyAccessToken) ?? Future.value(true),
      preferences?.remove(AppConstants.keyRefreshToken) ?? Future.value(true),
      preferences?.remove(AppConstants.keyUserId) ?? Future.value(true),
      preferences?.remove(AppConstants.keyUserEmail) ?? Future.value(true),
      preferences?.remove(AppConstants.keyUserRole) ?? Future.value(true),
    ]);
  }

  Future<void> write(String key, String value) async {
    if (!kIsWeb) {
      try {
        await _storage.write(key: key, value: value);
      } catch (e) {
        debugPrint('⚠️ [SecureStorage] Write key fallback: $e');
      }
    }
    await preferences?.setString(key, value);
  }

  Future<String?> read(String key) async {
    if (!kIsWeb) {
      try {
        final val = await _storage.read(key: key);
        if (val != null) return val;
      } catch (e) {
        debugPrint('⚠️ [SecureStorage] Read key fallback: $e');
      }
    }
    return preferences?.getString(key);
  }

  Future<void> delete(String key) async {
    if (!kIsWeb) {
      try {
        await _storage.delete(key: key);
      } catch (e) {
        debugPrint('⚠️ [SecureStorage] Delete key fallback: $e');
      }
    }
    await preferences?.remove(key);
  }

  Future<void> deleteAll() async {
    if (!kIsWeb) {
      try {
        await _storage.deleteAll();
      } catch (e) {
        debugPrint('⚠️ [SecureStorage] DeleteAll fallback: $e');
      }
    }
  }
}
