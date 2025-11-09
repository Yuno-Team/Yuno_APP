import '../models/policy.dart';
import '../models/policy_filter.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';

class PolicyService {
  static final PolicyService _instance = PolicyService._internal();
  factory PolicyService() => _instance;
  PolicyService._internal();

  final ApiClient _apiClient = ApiClient();

  Future<List<Policy>> getRecommendedPolicies({
    List<String> interests = const [],
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': '2',
      };

      if (interests.isNotEmpty) {
        queryParams['interests'] = interests.join(',');
      }

      final response = await _apiClient.get(
        ApiConstants.policiesRecommended,
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((json) => Policy.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('추천 정책 조회 오류: $e');
      return [];
    }
  }

  Future<List<Policy>> getPopularPolicies() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.policiesPopular,
        queryParameters: {'limit': '3'},
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data']['policies'] ?? response['data'];
        return data.map((json) => Policy.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('인기 정책 조회 오류: $e');
      return [];
    }
  }

  Future<List<Policy>> getUpcomingDeadlines() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.policiesUpcoming,
        queryParameters: {'limit': '3'},
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data']['policies'] ?? response['data'];
        return data.map((json) => Policy.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('마감임박 정책 조회 오류: $e');
      return [];
    }
  }

  Future<List<Policy>> searchPolicies(String query, {PolicyFilter? filter}) async {
    try {
      final queryParams = <String, String>{
        'page': '1',
        'limit': '20',
      };

      if (query.isNotEmpty) {
        queryParams['query'] = query;
      }

      // 필터 파라미터 추가
      if (filter != null) {
        final filterJson = filter.toApiJson();
        filterJson.forEach((key, value) {
          if (value != null) {
            queryParams[key] = value.toString();
          }
        });
      }

      final response = await _apiClient.get(
        ApiConstants.policiesSearch,
        queryParameters: queryParams,
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data']['policies'] ?? response['data'];
        return data.map((json) => Policy.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('정책 검색 오류: $e');
      return [];
    }
  }

  Future<Policy?> getPolicyDetail(String policyId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.policyDetail(policyId),
      );

      if (response['success'] == true && response['data'] != null) {
        return Policy.fromJson(response['data']);
      }

      return null;
    } catch (e) {
      print('정책 상세 조회 오류: $e');
      return null;
    }
  }

  Future<bool> bookmarkPolicy(String policyId) async {
    // TODO: 백엔드에서 북마크 API가 활성화되면 구현
    // 현재는 로컬에서만 처리하거나 향후 구현 예정
    print('북마크 저장: $policyId');
    return true;
  }

  Future<bool> unbookmarkPolicy(String policyId) async {
    // TODO: 백엔드에서 북마크 API가 활성화되면 구현
    print('북마크 해제: $policyId');
    return true;
  }
}
