import 'package:rental_management/core/constants/app_constants.dart';
import 'package:rental_management/core/network/api_client.dart';
import 'package:rental_management/features/auth/data/models/auth_tokens_model.dart';
import 'package:rental_management/features/auth/data/models/user_model.dart';

/// Contract for Remote Authentication Data Source
abstract class AuthRemoteDataSource {
  Future<AuthTokensModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<AuthTokensModel> refreshToken(String refreshToken);

  Future<UserModel> getCurrentUser();
}

/// Remote Data Source implementation using ApiClient (Dio)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthTokensModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      AppConstants.endpointLogin,
      data: {
        'email': email.trim(),
        'password': password,
      },
    );

    final rawData = response.data;
    final Map<String, dynamic> data = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return AuthTokensModel.fromJson(data);
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post(AppConstants.endpointLogout);
    } catch (_) {
      // Ignore network errors on logout since local tokens will be wiped anyway
    }
  }

  @override
  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    final response = await _apiClient.post(
      AppConstants.endpointRefresh,
      data: {'refreshToken': refreshToken},
    );

    final rawData = response.data;
    final Map<String, dynamic> data = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return AuthTokensModel.fromJson(data);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(AppConstants.endpointCurrentUser);

    final rawData = response.data;
    final Map<String, dynamic> data = rawData is Map<String, dynamic>
        ? (rawData['data'] is Map<String, dynamic>
            ? rawData['data'] as Map<String, dynamic>
            : rawData)
        : <String, dynamic>{};

    return UserModel.fromJson(data);
  }
}
