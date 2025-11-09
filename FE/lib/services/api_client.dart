import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();

  // GET 요청
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParameters);

      final response = await _client
          .get(
            uri,
            headers: _buildHeaders(headers),
          )
          .timeout(ApiConstants.receiveTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('네트워크 오류가 발생했습니다: $e');
    }
  }

  // POST 요청
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: _buildHeaders(headers),
            body: json.encode(body),
          )
          .timeout(ApiConstants.receiveTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('네트워크 오류가 발생했습니다: $e');
    }
  }

  // PUT 요청
  Future<Map<String, dynamic>> put(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse(url),
            headers: _buildHeaders(headers),
            body: json.encode(body),
          )
          .timeout(ApiConstants.receiveTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('네트워크 오류가 발생했습니다: $e');
    }
  }

  // DELETE 요청
  Future<Map<String, dynamic>> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .delete(
            Uri.parse(url),
            headers: _buildHeaders(headers),
          )
          .timeout(ApiConstants.receiveTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('네트워크 오류가 발생했습니다: $e');
    }
  }

  // 헤더 빌드
  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  // 응답 처리
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      } catch (e) {
        throw ApiException('응답 데이터 파싱 오류: $e');
      }
    } else if (response.statusCode == 400) {
      throw ApiException('잘못된 요청입니다.');
    } else if (response.statusCode == 401) {
      throw ApiException('인증이 필요합니다.');
    } else if (response.statusCode == 403) {
      throw ApiException('권한이 없습니다.');
    } else if (response.statusCode == 404) {
      throw ApiException('요청한 리소스를 찾을 수 없습니다.');
    } else if (response.statusCode == 429) {
      throw ApiException('요청이 너무 많습니다. 잠시 후 다시 시도해주세요.');
    } else if (response.statusCode >= 500) {
      throw ApiException('서버 오류가 발생했습니다.');
    } else {
      throw ApiException('알 수 없는 오류가 발생했습니다. (${response.statusCode})');
    }
  }

  // 헬스체크
  Future<bool> healthCheck() async {
    try {
      final response = await get(ApiConstants.health);
      return response['status'] == 'OK';
    } catch (e) {
      return false;
    }
  }

  // 클라이언트 종료
  void close() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}
