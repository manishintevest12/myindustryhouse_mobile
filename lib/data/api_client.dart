import 'package:dio/dio.dart';

import '../core/app_config.dart';

/// Thin Dio wrapper around the EXISTING backend. It only attaches session
/// headers, maps transport errors to friendly messages, and enforces
/// timeouts. Business logic stays 100% on the server - untouched.
class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.apiConnectTimeout,
        receiveTimeout: AppConfig.apiReceiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );
  }

  static final ApiClient instance = ApiClient._();

  late final Dio _dio;

  /// Called by the session provider after login (and after restoring a
  /// persisted session) so every request carries the auth context.
  void attachSession({String? token, String? email}) {
    // Web parity: SMS account sessions are sent as a Bearer token.
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  void clearSession() {
    _dio.options.headers.remove('Authorization');
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async =>
      _run(() => _dio.get<Map<String, dynamic>>(path, queryParameters: query));

  Future<Map<String, dynamic>> post(String path, {Object? body}) async =>
      _run(() => _dio.post<Map<String, dynamic>>(path, data: body));

  Future<Map<String, dynamic>> postWithToken(String path,
          {required String token, Object? body}) async =>
      _run(() => _dio.post<Map<String, dynamic>>(path,
          data: body,
          options: Options(headers: {'Authorization': 'Bearer $token'})));

  Future<Map<String, dynamic>> put(String path, {Object? body}) async =>
      _run(() => _dio.put<Map<String, dynamic>>(path, data: body));

  Future<Map<String, dynamic>> delete(String path) async =>
      _run(() => _dio.delete<Map<String, dynamic>>(path));

  Future<Map<String, dynamic>> _run(
      Future<Response<Map<String, dynamic>>> Function() call) async {
    try {
      final res = await call();
      return res.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      // One retry for genuine transport failures (flaky mobile data,
      // DNS hiccup) before reporting - HTTP errors are never retried.
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        try {
          final res = await call();
          return res.data ?? <String, dynamic>{};
        } on DioException catch (e2) {
          return _asError(e2);
        }
      }
      return _asError(e);
    }
  }

  Map<String, dynamic> _asError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      // Backend's own honest error envelope - surface it as-is.
      return {
        ...data,
        '__http_error': e.response?.statusCode,
      };
    }
    return {
      'success': false,
      '__transport_error': e.type.name,
      'message': _friendly(e),
    };
  }

  String _friendly(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          'The server took too long to respond. Check your connection and try again.',
        DioExceptionType.connectionError =>
          'Could not reach ${AppConfig.apiBaseUrl}. Check your internet connection and retry.',
        _ => 'Something went wrong talking to the server. Please try again.',
      };
}
