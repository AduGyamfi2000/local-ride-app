import 'package:dio/dio.dart';
import '../../core/errors/failures.dart';

class ApiClient {
  final Dio _dio;
  static const String baseUrl = 'http://localhost:8080/api/v1';

  ApiClient({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    _dio.interceptors.add(_LoggingInterceptor());
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: Options(headers: token != null ? {'Authorization': 'Bearer $token'} : null),
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    String? token,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        options: Options(headers: token != null ? {'Authorization': 'Bearer $token'} : null),
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    String? token,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        options: Options(headers: token != null ? {'Authorization': 'Bearer $token'} : null),
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    String? token,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        options: Options(headers: token != null ? {'Authorization': 'Bearer $token'} : null),
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(DioException error) {
    if (error.response?.statusCode == 401) {
      throw ServerFailure('Unauthorized - Token expired');
    } else if (error.response?.statusCode == 403) {
      throw ServerFailure('Forbidden - Access denied');
    } else if (error.response?.statusCode == 404) {
      throw ServerFailure('Not found');
    } else if (error.type == DioExceptionType.connectionTimeout) {
      throw NetworkFailure('Connection timeout');
    } else if (error.type == DioExceptionType.receiveTimeout) {
      throw NetworkFailure('Request timeout');
    } else {
      throw ServerFailure(error.message ?? 'Unknown error');
    }
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🔴 REQUEST: ${options.method} ${options.path}');
    print('Headers: ${options.headers}');
    if (options.data != null) print('Data: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('🟢 RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('🔵 ERROR: ${err.response?.statusCode} ${err.message}');
    handler.next(err);
  }
}
