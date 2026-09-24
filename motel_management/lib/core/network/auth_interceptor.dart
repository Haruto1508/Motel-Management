import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rental_management/app/config/app_environment.dart';
import 'package:rental_management/core/constants/app_constants.dart';
import 'package:rental_management/core/storage/secure_storage_service.dart';

/// Interceptor responsible for:
/// 1. Attaching Access Token as Bearer in Authorization header
/// 2. Intercepting 401 Unauthorized errors
/// 3. Refreshing token via refresh endpoint
/// 4. Retrying the failed request with new access token
/// 5. Triggering logout when refresh token is invalid/expired
class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  final SecureStorageService storage;
  final VoidCallback onSessionExpired;

  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;

  AuthInterceptor({
    required this.dio,
    required this.storage,
    required this.onSessionExpired,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token attachment for auth endpoints
    final isAuthEndpoint = options.path.contains(AppConstants.endpointLogin) ||
        options.path.contains(AppConstants.endpointRefresh);

    if (!isAuthEndpoint) {
      final token = await storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final requestOptions = err.requestOptions;

    // Check if the failure is 401 Unauthorized
    final is401 = response?.statusCode == 401;
    final isRefreshEndpoint =
        requestOptions.path.contains(AppConstants.endpointRefresh);
    final isLoginEndpoint =
        requestOptions.path.contains(AppConstants.endpointLogin);

    // If 401 occurs on refresh endpoint or login endpoint, session is expired
    if (is401 && (isRefreshEndpoint || isLoginEndpoint)) {
      await storage.clearAuthTokens();
      onSessionExpired();
      return handler.next(err);
    }

    if (is401) {
      // Prevent retry loop
      final hasAlreadyRetried =
          requestOptions.extra['isRetryAfterTokenRefresh'] == true;
      if (hasAlreadyRetried) {
        await storage.clearAuthTokens();
        onSessionExpired();
        return handler.next(err);
      }

      try {
        final newAccessToken = await _refreshToken();
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          // Retry failed request with new token
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          requestOptions.extra['isRetryAfterTokenRefresh'] = true;

          final retryResponse = await dio.fetch(requestOptions);
          return handler.resolve(retryResponse);
        } else {
          await storage.clearAuthTokens();
          onSessionExpired();
          return handler.next(err);
        }
      } catch (refreshErr) {
        await storage.clearAuthTokens();
        onSessionExpired();
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  /// Refreshes the access token using a mutex lock to avoid duplicate refreshes.
  Future<String?> _refreshToken() async {
    if (_isRefreshing) {
      return await _refreshCompleter?.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();

    try {
      final refreshToken = await storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _refreshCompleter?.complete(null);
        return null;
      }

      // Use a separate Dio instance without interceptors to prevent circular calls
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: AppEnvironment.apiBaseUrl,
          connectTimeout: AppEnvironment.connectTimeout,
          receiveTimeout: AppEnvironment.receiveTimeout,
        ),
      );

      final response = await refreshDio.post(
        AppConstants.endpointRefresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};

        final newAccessToken = data['accessToken'] as String? ??
            data['data']?['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String? ??
            data['data']?['refreshToken'] as String? ??
            refreshToken;

        if (newAccessToken != null) {
          await storage.saveAuthTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          _refreshCompleter?.complete(newAccessToken);
          return newAccessToken;
        }
      }

      _refreshCompleter?.complete(null);
      return null;
    } catch (e) {
      debugPrint('Failed to refresh token: $e');
      _refreshCompleter?.complete(null);
      return null;
    } finally {
      _isRefreshing = false;
    }
  }
}
