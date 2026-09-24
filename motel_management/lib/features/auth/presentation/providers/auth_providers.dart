import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_management/core/network/api_client.dart';
import 'package:rental_management/core/storage/preferences_service.dart';
import 'package:rental_management/core/storage/secure_storage_service.dart';
import 'package:rental_management/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rental_management/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rental_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:rental_management/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:rental_management/features/auth/domain/usecases/login_usecase.dart';
import 'package:rental_management/features/auth/domain/usecases/logout_usecase.dart';
import 'package:rental_management/features/auth/presentation/providers/auth_controller.dart';
import 'package:rental_management/features/auth/presentation/providers/auth_state.dart';

// --- Core Providers ---

final Provider<SecureStorageService> secureStorageProvider =
    Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final Provider<PreferencesService> preferencesServiceProvider =
    Provider<PreferencesService>((ref) {
  throw UnimplementedError('PreferencesService must be initialized in main()');
});

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);

  return ApiClient(
    secureStorage: secureStorage,
    onSessionExpired: () {
      ref.read(authControllerProvider.notifier).handleSessionExpired();
    },
  );
});

// --- Feature: Auth Data Sources & Repositories ---

final Provider<AuthRemoteDataSource> authRemoteDataSourceProvider =
    Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient);
});

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final preferences = ref.watch(preferencesServiceProvider);

  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    secureStorage: secureStorage,
    preferences: preferences,
  );
});

// --- Feature: Auth Use Cases ---

final Provider<LoginUseCase> loginUseCaseProvider =
    Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final Provider<LogoutUseCase> logoutUseCaseProvider =
    Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final Provider<GetCurrentUserUseCase> getCurrentUserUseCaseProvider =
    Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

// --- Feature: Auth State Controller ---

final StateNotifierProvider<AuthController, AuthState> authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final logoutUseCase = ref.watch(logoutUseCaseProvider);
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);

  return AuthController(
    authRepository: authRepository,
    loginUseCase: loginUseCase,
    logoutUseCase: logoutUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
  );
});
