import 'package:equatable/equatable.dart';
import 'package:rental_management/core/errors/exceptions.dart';

/// Base class representing failure states returned by Domain layer repositories & use cases.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  final dynamic details;

  const Failure(this.message, {this.statusCode, this.details});

  @override
  List<Object?> get props => [message, statusCode, details];

  /// Factory helper to map exceptions to corresponding failures
  factory Failure.fromException(AppException exception) {
    if (exception is NetworkException) {
      return NetworkFailure(exception.message, statusCode: exception.statusCode);
    } else if (exception is TimeoutException) {
      return TimeoutFailure(exception.message, statusCode: exception.statusCode);
    } else if (exception is UnauthorizedException) {
      return UnauthorizedFailure(exception.message, statusCode: exception.statusCode);
    } else if (exception is ForbiddenException) {
      return ForbiddenFailure(exception.message, statusCode: exception.statusCode);
    } else if (exception is NotFoundException) {
      return NotFoundFailure(exception.message, statusCode: exception.statusCode);
    } else if (exception is ValidationException) {
      return ValidationFailure(
        exception.message,
        statusCode: exception.statusCode,
        errors: exception.errors,
      );
    } else if (exception is ServerException) {
      return ServerFailure(exception.message, statusCode: exception.statusCode);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    }
    return UnknownFailure(exception.message, statusCode: exception.statusCode);
  }
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.statusCode});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message, {super.statusCode});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message, {super.statusCode});
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message, {super.statusCode});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.statusCode});
}

class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;

  const ValidationFailure(
    super.message, {
    super.statusCode,
    this.errors,
  });

  @override
  List<Object?> get props => [message, statusCode, errors];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.statusCode, super.details});
}
