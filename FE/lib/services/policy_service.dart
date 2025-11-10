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
        'limit': '100', // 마감임박 필터링을 위해 더 많이 가져오기
      };

      if (query.isNotEmpty) {
        queryParams['query'] = query;
      }

      // 필터 파라미터 추가
      bool isDeadlineImminentFilter = false;
      if (filter != null) {
        final filterJson = filter.toApiJson();
        if (filterJson['deadlineImminent'] == true) {
          isDeadlineImminentFilter = true;
        }
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
        List<Policy> policies = data.map((json) => Policy.fromJson(json)).toList();

        // 마감 임박 필터: bizPrdEndYmd 기준으로 7일 이내만 필터링
        if (isDeadlineImminentFilter) {
          final now = DateTime.now().toLocal();
          final nowOnly = DateTime(now.year, now.month, now.day);
          final sevenDaysLater = nowOnly.add(Duration(days: 7));

          policies = policies.where((policy) {
            if (policy.bizPrdEndYmd != null && policy.bizPrdEndYmd!.length == 8) {
              try {
                final dateStr = policy.bizPrdEndYmd!;
                final endDate = DateTime.parse(
                  '${dateStr.substring(0, 4)}-${dateStr.substring(4, 6)}-${dateStr.substring(6, 8)}'
                );
                final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

                // 오늘보다 이후이고, 7일 이내인 정책
                return endDateOnly.isAfter(nowOnly) &&
                       endDateOnly.isBefore(sevenDaysLater.add(Duration(days: 1)));
              } catch (e) {
                return false;
              }
            }
            return false;
          }).toList();

          print('📅 Filtered ${policies.length} policies within 7 days');
        }

        return policies;
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

  // 최근 추가된 정책 수 조회 (7일 이내)
  Future<int> getRecentlyAddedCount() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.policiesSearch,
        queryParameters: {
          'recentlyAdded': 'true',
          'limit': '1',
        },
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data']['total'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('최근 추가 정책 수 조회 오류: $e');
      return 0;
    }
  }

  // 신청 마감 임박 정책 수 조회 (7일 이내, bizPrdEndYmd 기준)
  Future<int> getDeadlineImminentCount() async {
    try {
      // deadline_approaching_policies 뷰에서 모든 정책 가져오기
      final response = await _apiClient.get(
        ApiConstants.policiesUpcoming,
        queryParameters: {
          'limit': '100',
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> policiesData = response['data']['policies'] ?? response['data'];
        final policies = policiesData.map((json) => Policy.fromJson(json)).toList();

        // 7일 이내 마감 정책만 필터링
        final now = DateTime.now().toLocal();
        final nowOnly = DateTime(now.year, now.month, now.day);
        final sevenDaysLater = nowOnly.add(Duration(days: 7));

        int count = 0;
        for (var policy in policies) {
          if (policy.bizPrdEndYmd != null && policy.bizPrdEndYmd!.length == 8) {
            try {
              final dateStr = policy.bizPrdEndYmd!;
              final endDate = DateTime.parse(
                '${dateStr.substring(0, 4)}-${dateStr.substring(4, 6)}-${dateStr.substring(6, 8)}'
              );
              final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

              // 오늘보다 이후이고, 7일 이내인 정책
              if (endDateOnly.isAfter(nowOnly) && endDateOnly.isBefore(sevenDaysLater.add(Duration(days: 1)))) {
                count++;
              }
            } catch (e) {
              // 날짜 파싱 실패시 무시
            }
          }
        }

        return count;
      }
      return 0;
    } catch (e) {
      print('마감 임박 정책 수 조회 오류: $e');
      return 0;
    }
  }
}
