class AppException implements Exception {
  final String message;
  final int? statusCode;
  final String? prefix;

  AppException({
    required this.message,
    this.statusCode,
    this.prefix,
  });

  @override
  String toString() => '${prefix ?? "Error"}: $message (Code: $statusCode)';
}

class NetworkException extends AppException {
  NetworkException({
    String message = 'No Internet connection or server unreachable.',
    int? statusCode,
  }) : super(message: message, statusCode: statusCode, prefix: 'Network Error');
}

class BadRequestException extends AppException {
  BadRequestException({
    required String message,
    int? statusCode = 400,
  }) : super(message: message, statusCode: statusCode, prefix: 'Bad Request');
}

class UnauthorizedException extends AppException {
  UnauthorizedException({
    String message = 'Session expired or unauthorized. Please log in again.',
    int? statusCode = 401,
  }) : super(message: message, statusCode: statusCode, prefix: 'Unauthorized');
}

class ForbiddenException extends AppException {
  ForbiddenException({
    String message = 'You do not have permission to perform this action.',
    int? statusCode = 403,
  }) : super(message: message, statusCode: statusCode, prefix: 'Forbidden');
}

class NotFoundException extends AppException {
  NotFoundException({
    required String message,
    int? statusCode = 404,
  }) : super(message: message, statusCode: statusCode, prefix: 'Not Found');
}

class ConflictException extends AppException {
  ConflictException({
    required String message,
    int? statusCode = 409,
  }) : super(message: message, statusCode: statusCode, prefix: 'Conflict');
}

class ServerException extends AppException {
  ServerException({
    String message = 'An unexpected internal server error occurred.',
    int? statusCode = 500,
  }) : super(message: message, statusCode: statusCode, prefix: 'Server Error');
}

class TimeoutException extends AppException {
  TimeoutException({
    String message = 'Connection timed out. Please try again.',
  }) : super(message: message, prefix: 'Timeout');
}