import 'dart:convert';
import 'package:rental_management/core/storage/preferences_service.dart';
import 'package:rental_management/core/storage/secure_storage_service.dart';
import 'package:rental_management/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rental_management/features/auth/data/models/user_model.dart';
import 'package:rental_management/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:rental_management/features/auth/domain/entities/user_entity.dart';
import 'package:rental_management/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository bridging remote data source, secure storage, and local cache.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;
  final PreferencesService preferences;

  static const String _cachedUserKey = 'cached_current_user';

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
    required this.preferences,
  });

  @override
  Future<AuthTokensEntity> login({
    required String email,
    required String password,
  }) async {
    final tokensModel = await remoteDataSource.login(
      email: email,
      password: password,
    );

    // Save tokens securely
    await secureStorage.saveAuthTokens(
      accessToken: tokensModel.accessToken,
      refreshToken: tokensModel.refreshToken,
    );

    return tokensModel.toEntity();
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } finally {
      // Always wipe credentials and cached user
      await secureStorage.clearAuthTokens();
      await preferences.remove(_cachedUserKey);
    }
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      // Cache user info locally for offline viewing
      await preferences.setString(
        _cachedUserKey,
        jsonEncode(userModel.toJson()),
      );
      return userModel.toEntity();
    } catch (e) {
      // Fallback to cached user if offline
      final cachedJson = preferences.getString(_cachedUserKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final Map<String, dynamic> data =
            jsonDecode(cachedJson) as Map<String, dynamic>;
        return UserModel.fromJson(data).toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<AuthTokensEntity> refreshToken(String refreshToken) async {
    final tokensModel = await remoteDataSource.refreshToken(refreshToken);
    await secureStorage.saveAuthTokens(
      accessToken: tokensModel.accessToken,
      refreshToken: tokensModel.refreshToken,
    );
    return tokensModel.toEntity();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
