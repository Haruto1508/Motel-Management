import 'package:rental_management/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:rental_management/features/auth/domain/entities/user_entity.dart';

/// Abstract AuthRepository defining contracts for authentication actions.
abstract class AuthRepository {
  /// Authenticates user with email and password
  Future<AuthTokensEntity> login({
    required String email,
    required String password,
  });

  /// Logs out current user and removes stored tokens
  Future<void> logout();

  /// Retrieves currently authenticated user details
  Future<UserEntity> getCurrentUser();

  /// Refreshes the session using the stored refresh token
  Future<AuthTokensEntity> refreshToken(String refreshToken);

  /// Checks if there is a currently saved session / access token
  Future<bool> isAuthenticated();
}
