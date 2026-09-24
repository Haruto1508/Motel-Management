import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rental_management/app/config/app_environment.dart';
import 'package:rental_management/core/errors/exceptions.dart';
import 'package:rental_management/core/network/auth_interceptor.dart';
import 'package:rental_management/core/storage/secure_storage_service.dart';

/// Central HTTP Client wrapper around Dio with robust interceptors and error translation.
class ApiClient {
  final Dio dio;

  ApiClient({
    required SecureStorageService secureStorage,
    required VoidCallback onSessionExpired,
    String? baseUrl,
  }) : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? AppEnvironment.apiBaseUrl,
            connectTimeout: AppEnvironment.connectTimeout,
            receiveTimeout: AppEnvironment.receiveTimeout,
            sendTimeout: AppEnvironment.sendTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            validateStatus: (status) => status != null && status >= 200 && status < 300,
          ),
        ) {
    // Add AuthInterceptor
    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        storage: secureStorage,
        onSessionExpired: onSessionExpired,
      ),
    );

    // Add safe LoggingInterceptor for debug mode (masking sensitive fields)
    if (kDebugMode) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            debugPrint('🌐 [DIO REQ] [${options.method}] ${options.uri}');
            return handler.next(options);
          },
          onResponse: (response, handler) {
            debugPrint(
              '✅ [DIO RES] [${response.statusCode}] ${response.requestOptions.uri}',
            );
            return handler.next(response);
          },
          onError: (DioException err, handler) {
            debugPrint(
              '❌ [DIO ERR] [${err.response?.statusCode}] ${err.requestOptions.uri} -> ${err.message}',
            );
            return handler.next(err);
          },
        ),
      );
    }
  }

  /// Translates [DioException] and raw exceptions to strongly-typed [AppException].
  static AppException handleDioError(dynamic error) {
    if (error is AppException) return error;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const TimeoutException();

        case DioExceptionType.connectionError:
          return const NetworkException();

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;

          String serverMessage = 'Đã xảy ra lỗi.';
          Map<String, dynamic>? validationErrors;

          if (responseData is Map<String, dynamic>) {
            if (responseData['message'] is String) {
              serverMessage = responseData['message'] as String;
            } else if (responseData['error'] is String) {
              serverMessage = responseData['error'] as String;
            }

            if (responseData['errors'] is Map<String, dynamic>) {
              validationErrors = responseData['errors'] as Map<String, dynamic>;
            }
          }

          if (statusCode == 400 || statusCode == 422) {
            return ValidationException(
              serverMessage,
              statusCode: statusCode,
              errors: validationErrors,
            );
          } else if (statusCode == 401) {
            return UnauthorizedException(serverMessage, statusCode);
          } else if (statusCode == 403) {
            return ForbiddenException(serverMessage, statusCode);
          } else if (statusCode == 404) {
            return NotFoundException(serverMessage, statusCode);
          } else if (statusCode != null && statusCode >= 500) {
            return ServerException(serverMessage, statusCode);
          }

          return UnknownException(serverMessage, statusCode);

        case DioExceptionType.cancel:
          return const UnknownException('Yêu cầu đã bị hủy bỏ.');

        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return const NetworkException();
          }
          return UnknownException(error.message ?? 'Lỗi không xác định.');

        default:
          return const UnknownException();
      }
    }

    return UnknownException(error?.toString() ?? 'Đã xảy ra lỗi không xác định.');
  }

  // HTTP Helper methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw handleDioError(e);
    }
  }
}
