import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../errors/app_exceptions.dart';
import '../storage/secure_storage_service.dart';

class HttpClient {
  final Dio _dio;
  final SecureStorageService _secureStorage;

  HttpClient({
    Dio? dio,
    SecureStorageService? secureStorage,
  })  : _dio = dio ?? Dio(),
        _secureStorage = secureStorage ?? SecureStorageService() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          final appException = _mapDioError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: appException,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  Dio get instance => _dio;

  AppException _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();

      case DioExceptionType.badResponse:
        final response = error.response;
        final statusCode = response?.statusCode;
        final data = response?.data;
        String message = 'Something went wrong';

        if (data is Map<String, dynamic> && data.containsKey('errorMessage')) {
          message = data['errorMessage'];
        } else if (data is Map<String, dynamic> && data.containsKey('message')) {
          message = data['message'];
        }

        switch (statusCode) {
          case 400:
            return BadRequestException(message: message, statusCode: statusCode);
          case 401:
            return UnauthorizedException(message: message, statusCode: statusCode);
          case 403:
            return ForbiddenException(message: message, statusCode: statusCode);
          case 404:
            return NotFoundException(message: message, statusCode: statusCode);
          case 409:
            return ConflictException(message: message, statusCode: statusCode);
          case 500:
          default:
            return ServerException(message: message, statusCode: statusCode);
        }

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      default:
        return NetworkException();
    }
  }

  // Generic Request Helper Methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw e.error as AppException;
    }
  }
}