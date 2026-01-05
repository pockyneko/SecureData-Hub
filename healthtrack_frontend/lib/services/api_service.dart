import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

/// API 响应封装
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? code;
  final List<dynamic>? errors;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.code,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : json['data'],
      message: json['message'],
      code: json['code'],
      errors: json['errors'],
    );
  }
}

/// API 异常
class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final List<dynamic>? errors;

  ApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => message;
}

/// 基础 API 服务
class ApiService {
  final String baseUrl;
  String? _accessToken;
  String? _refreshToken;

  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? ApiConstants.baseUrl;

  // Token 设置
  void setTokens({String? accessToken, String? refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  // 构建请求头
  Map<String, String> _buildHeaders({bool requireAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (requireAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  // 处理响应
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw ApiException(
      message: body['message'] ?? '请求失败',
      code: body['code'],
      statusCode: response.statusCode,
      errors: body['errors'],
    );
  }

  // GET 请求
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requireAuth = false,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(
        uri,
        headers: _buildHeaders(requireAuth: requireAuth),
      ).timeout(const Duration(milliseconds: ApiConstants.connectTimeout));

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: '网络请求失败: $e');
    }
  }

  // POST 请求
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(requireAuth: requireAuth),
        body: body != null ? json.encode(body) : null,
      ).timeout(const Duration(milliseconds: ApiConstants.connectTimeout));

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: '网络请求失败: $e');
    }
  }

  // PUT 请求
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = false,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(requireAuth: requireAuth),
        body: body != null ? json.encode(body) : null,
      ).timeout(const Duration(milliseconds: ApiConstants.connectTimeout));

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: '网络请求失败: $e');
    }
  }

  // DELETE 请求
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requireAuth = false,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(requireAuth: requireAuth),
      ).timeout(const Duration(milliseconds: ApiConstants.connectTimeout));

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: '网络请求失败: $e');
    }
  }
}
