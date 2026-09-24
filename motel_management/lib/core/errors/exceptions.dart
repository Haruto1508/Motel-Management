/// Base exception class for all application-level exceptions.
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const AppException(this.message, {this.statusCode, this.details});

  @override
  String toString() => '$runtimeType: $message (status: $statusCode)';
}

/// Thrown when there is no internet connection or network request failed
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Không có kết nối mạng. Vui lòng kiểm tra lại đường truyền.',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

/// Thrown when a network request times out (connect, send, receive)
class TimeoutException extends AppException {
  const TimeoutException([
    super.message = 'Yêu cầu hết thời gian chờ. Vui lòng thử lại sau.',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

/// Thrown when user is unauthorized (401)
class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Phiên đăng nhập đã hết hạn hoặc không hợp lệ. Vui lòng đăng nhập lại.',
    int? statusCode = 401,
  ]) : super(statusCode: statusCode);
}

/// Thrown when user lacks permission to access resource (403)
class ForbiddenException extends AppException {
  const ForbiddenException([
    super.message = 'Bạn không có quyền thực hiện thao tác này.',
    int? statusCode = 403,
  ]) : super(statusCode: statusCode);
}

/// Thrown when requested resource is not found (404)
class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'Không tìm thấy dữ liệu yêu cầu.',
    int? statusCode = 404,
  ]) : super(statusCode: statusCode);
}

/// Thrown when backend returns validation errors (400 or 422)
class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  const ValidationException(
    super.message, {
    super.statusCode = 400,
    this.errors,
  });
}

/// Thrown when server errors occur (500+)
class ServerException extends AppException {
  const ServerException([
    super.message = 'Hệ thống máy chủ gặp sự cố. Vui lòng thử lại sau ít phút.',
    int? statusCode = 500,
  ]) : super(statusCode: statusCode);
}

/// Thrown when cache or local database operations fail
class CacheException extends AppException {
  const CacheException([
    super.message = 'Lỗi truy xuất bộ nhớ cục bộ.',
  ]);
}

/// General or unexpected application exception
class UnknownException extends AppException {
  const UnknownException([
    super.message = 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.',
    int? statusCode,
    dynamic details,
  ]) : super(statusCode: statusCode, details: details);
}
