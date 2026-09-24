import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_management/core/errors/exceptions.dart';
import 'package:rental_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:rental_management/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:rental_management/features/auth/domain/usecases/login_usecase.dart';
import 'package:rental_management/features/auth/domain/usecases/logout_usecase.dart';
import 'package:rental_management/features/auth/presentation/providers/auth_state.dart';

/// Riverpod StateNotifier controlling authentication lifecycle and state transitions.
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthController({
    required this.authRepository,
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthState.initial()) {
    checkAuthStatus();
  }

  /// Verifies if user has an active session and loads current user profile
  Future<void> checkAuthStatus() async {
    try {
      final isAuth = await authRepository.isAuthenticated();
      if (!isAuth) {
        state = const AuthState.unauthenticated();
        return;
      }

      final user = await getCurrentUserUseCase();
      state = AuthState.authenticated(user);
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  /// Performs user login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.authenticating();
    try {
      await loginUseCase(LoginParams(email: email, password: password));
      final user = await getCurrentUserUseCase();
      state = AuthState.authenticated(user);
      return true;
    } on AppException catch (e) {
      state = AuthState.error(e.message);
      return false;
    } catch (e) {
      state = const AuthState.error('Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.');
      return false;
    }
  }

  /// Logs out the user and cleans up tokens
  Future<void> logout() async {
    try {
      await logoutUseCase();
    } finally {
      state = const AuthState.unauthenticated();
    }
  }

  /// Invoked by AuthInterceptor when refresh token fails/expires
  void handleSessionExpired() {
    state = const AuthState.unauthenticated();
  }
}
