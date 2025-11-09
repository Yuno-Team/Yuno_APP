class ApiConstants {
  // 백엔드 베이스 URL
  // 로컬 개발: http://localhost:3000
  // AWS EC2 서버: http://43.200.164.71
  // 프로덕션: https://api.yuno.app
  static const String baseUrl = 'http://localhost:3000';

  // API 엔드포인트
  static const String apiPrefix = '/api';

  // Policy 관련 엔드포인트
  static const String policiesPath = '/policies';
  static const String policiesSearchPath = '/policies/search';
  static const String policiesRecommendedPath = '/policies/recommended';
  static const String policiesPopularPath = '/policies/lists/popular';
  static const String policiesUpcomingPath = '/policies/lists/deadline';

  // LH 주거 관련 엔드포인트
  static const String lhPath = '/lh';

  // 인증 관련 엔드포인트 (현재 비활성화)
  // static const String authPath = '/auth';
  // static const String usersPath = '/users';

  // 타임아웃 설정
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // 헬스체크
  static const String healthPath = '/health';

  // Full URL helper methods
  static String get policies => '$baseUrl$apiPrefix$policiesPath';
  static String get policiesSearch => '$baseUrl$apiPrefix$policiesSearchPath';
  static String get policiesRecommended => '$baseUrl$apiPrefix$policiesRecommendedPath';
  static String get policiesPopular => '$baseUrl$apiPrefix$policiesPopularPath';
  static String get policiesUpcoming => '$baseUrl$apiPrefix$policiesUpcomingPath';
  static String get lh => '$baseUrl$apiPrefix$lhPath';
  static String get health => '$baseUrl$healthPath';

  static String policyDetail(String id) => '$baseUrl$apiPrefix$policiesPath/$id';
}
