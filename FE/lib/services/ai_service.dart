import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/policy.dart';

class AIService {
  // 개발 환경에서는 localhost
  static const String baseUrl = 'http://localhost:8000';

  /// AI 기반 정책 추천 (top 3개)
  static Future<List<Policy>> getRecommendations({
    required String userId,
    required int age,
    String? major,
    List<String>? interests,
    String? location,
    int topK = 3,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/recommendations?top_k=$topK'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'age': age,
          if (major != null && major.isNotEmpty) 'major': major,
          'interests': interests ?? [],
          if (location != null && location.isNotEmpty) 'location': location,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));

        if (jsonData['success'] == true) {
          List<Policy> policies = [];
          for (var item in jsonData['data']) {
            policies.add(Policy(
              id: item['id'] ?? '',
              plcyNm: item['plcyNm'] ?? '',
              bscPlanPlcyWayNoNm: item['bscPlanPlcyWayNoNm'] ?? '',
              plcyExplnCn: item['plcyExplnCn'],
              rgtrupInstCdNm: item['rgtrupInstCdNm'],
              aplyPrdSeCd: item['aplyPrdSeCd'],
              aplyPrdEndYmd: item['aplyPrdEndYmd'],
              bizPrdBgngYmd: item['bizPrdBgngYmd'],
              bizPrdEndYmd: item['bizPrdEndYmd'],
              applicationUrl: item['applicationUrl'],
              requirements: item['requirements'] != null
                  ? List<String>.from(item['requirements'])
                  : [],
              saves: item['saves'] ?? 0,
              isBookmarked: item['isBookmarked'] ?? false,
            ));
          }
          return policies;
        }
      }

      print('AI 추천 API 오류: ${response.statusCode}');
      return [];
    } catch (e) {
      print('AI Service Error: $e');
      return [];
    }
  }

  /// 정책 AI 요약 (Gemini 기반)
  static Future<String?> getPolicySummary({
    required String policyId,
    int? userAge,
    String? userMajor,
    List<String>? userInterests,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/summary'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'policy_id': policyId,
          if (userAge != null) 'user_age': userAge,
          if (userMajor != null && userMajor.isNotEmpty) 'user_major': userMajor,
          if (userInterests != null && userInterests.isNotEmpty) 'user_interests': userInterests,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));

        if (jsonData['success'] == true) {
          return jsonData['summary'];
        }
      }

      print('AI 요약 API 오류: ${response.statusCode}');
      return null;
    } catch (e) {
      print('AI Summary Error: $e');
      return null;
    }
  }

  /// AI 서버 헬스 체크
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
