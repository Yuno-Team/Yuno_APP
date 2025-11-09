# Yuno 앱 FE-BE 통합 가이드

## 완료된 작업

### 1. API 인프라 구축
- ✅ `lib/constants/api_constants.dart` - API 엔드포인트 상수 정의
- ✅ `lib/services/api_client.dart` - HTTP 클라이언트 래퍼

### 2. 데이터 모델 업데이트
- ✅ `lib/models/policy.dart` - 백엔드 응답 형식에 맞게 수정
- ✅ JSON 직렬화/역직렬화 개선

### 3. 서비스 레이어 실제 API 연동
- ✅ `lib/services/policy_service.dart` - 모든 API 호출 메서드 구현
  - `getRecommendedPolicies()` - 추천 정책 조회
  - `getPopularPolicies()` - 인기 정책 TOP3
  - `getUpcomingDeadlines()` - 마감 임박 정책
  - `searchPolicies()` - 정책 검색 (필터 포함)
  - `getPolicyDetail()` - 정책 상세 조회

### 4. 화면 업데이트
- ✅ `lib/screens/home_screen.dart` - 실제 API 데이터 사용
  - 추천 정책 섹션
  - 인기 정책 TOP3 섹션
  - 다가오는 일정 섹션
  - 로딩 상태 표시

- ✅ `lib/screens/explore_results_screen.dart` - 검색 결과 실제 API 연동
  - 정책 검색 및 필터링
  - 로딩 상태 표시

- ✅ `lib/screens/policy_detail_screen.dart` - 정책 상세 페이지 API 연동

## 실행 방법

### 백엔드 실행

1. 백엔드 디렉토리로 이동:
```bash
cd BE
```

2. 환경 변수 설정 (`.env` 파일 생성):
```bash
cp .env.example .env
# .env 파일을 열어 필요한 값 설정
```

3. 의존성 설치:
```bash
npm install
```

4. 데이터베이스 초기화 (PostgreSQL 필요):
```bash
npm run db:init
```

5. 서버 실행:
```bash
# 개발 모드
npm run dev

# 프로덕션 모드
npm start
```

서버가 http://localhost:3000 에서 실행됩니다.

### 프론트엔드 실행

1. 프론트엔드 디렉토리로 이동:
```bash
cd FE
```

2. 의존성 설치:
```bash
flutter pub get
```

3. API 베이스 URL 확인:
`lib/constants/api_constants.dart` 파일에서 `baseUrl` 확인
- 로컬 개발: `http://localhost:3000`
- 실제 기기 테스트 시: 컴퓨터의 로컬 IP 주소로 변경 (예: `http://192.168.1.100:3000`)

4. 앱 실행:
```bash
# iOS 시뮬레이터
flutter run -d ios

# Android 에뮬레이터
flutter run -d android

# Chrome (웹)
flutter run -d chrome
```

## API 엔드포인트

### 정책 관련
- `GET /api/policies/search` - 정책 검색
- `GET /api/policies/recommended` - 추천 정책
- `GET /api/policies/popular` - 인기 정책
- `GET /api/policies/upcoming` - 마감 임박 정책
- `GET /api/policies/:id` - 정책 상세

### 주거 관련
- `GET /api/lh` - LH 주거 정책

### 헬스체크
- `GET /health` - 서버 상태 확인

## 주요 변경사항

### API Constants (`lib/constants/api_constants.dart`)
```dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:3000';
  static const String apiPrefix = '/api';

  // 엔드포인트들...
  static String get policiesSearch => '$baseUrl$apiPrefix/policies/search';
  static String policyDetail(String id) => '$baseUrl$apiPrefix/policies/$id';
}
```

### API Client (`lib/services/api_client.dart`)
- HTTP 요청 래퍼 (GET, POST, PUT, DELETE)
- 에러 핸들링
- 타임아웃 설정 (30초)
- 자동 헤더 추가 (Content-Type, Accept)

### Policy Service 업데이트
- 모든 메서드가 실제 API 호출
- 에러 처리 및 로깅
- 필터 파라미터 전달

## 테스트 방법

### 1. 백엔드 헬스체크
```bash
curl http://localhost:3000/health
```

예상 응답:
```json
{
  "status": "OK",
  "timestamp": "2025-11-04T...",
  "uptime": 123.456,
  "environment": "development"
}
```

### 2. 정책 검색 테스트
```bash
curl "http://localhost:3000/api/policies/search?query=청년&limit=5"
```

### 3. 인기 정책 조회
```bash
curl "http://localhost:3000/api/policies/popular?limit=3"
```

### 4. 프론트엔드 테스트
1. 앱 실행
2. 홈 화면에서 데이터 로딩 확인
3. 탐색 탭에서 검색 기능 테스트
4. 정책 상세 페이지 확인

## 트러블슈팅

### 백엔드 연결 실패
**증상**: "네트워크 오류가 발생했습니다" 메시지

**해결방법**:
1. 백엔드 서버가 실행 중인지 확인
2. `lib/constants/api_constants.dart`의 `baseUrl` 확인
3. 실제 기기 테스트 시 localhost 대신 컴퓨터 IP 사용

### CORS 오류 (웹 실행 시)
**증상**: CORS policy 에러

**해결방법**:
백엔드의 CORS 설정이 올바른지 확인. `BE/src/app.js`에서 개발 환경은 모든 origin 허용됨.

### 데이터베이스 연결 오류
**증상**: "Database connection failed"

**해결방법**:
1. PostgreSQL이 실행 중인지 확인
2. `.env` 파일의 데이터베이스 설정 확인
3. 데이터베이스가 생성되어 있는지 확인

### 빈 데이터 응답
**증상**: 정책 목록이 비어있음

**해결방법**:
1. 백엔드에 정책 데이터가 있는지 확인
2. 온통청년 API 키가 설정되어 있는지 확인 (`.env` 파일)
3. 백엔드 로그 확인

## 아직 구현되지 않은 기능

### 인증 관련 (백엔드에서 비활성화됨)
- 소셜 로그인 (Google, Kakao, Naver, Apple)
- JWT 인증
- 사용자 프로필 관리

이 기능들은 백엔드 개발자가 활성화하면 프론트엔드에서 연동 가능합니다.

### 북마크 기능
- 백엔드 API가 활성화되면 구현 예정
- 현재는 로컬에서만 처리

## 다음 단계

1. **백엔드 데이터 채우기**
   - 온통청년 API 키 설정
   - 정책 데이터 동기화 실행

2. **실제 기기 테스트**
   - iOS/Android 실제 기기에서 테스트
   - 네트워크 연결 확인

3. **에러 핸들링 개선**
   - 더 자세한 에러 메시지
   - 재시도 로직 추가

4. **로딩 상태 개선**
   - 스켈레톤 UI 추가
   - Pull-to-refresh 구현

5. **캐싱 전략**
   - 로컬 캐시 구현
   - 오프라인 모드 지원

## 참고사항

- 디자인과 UI는 수정하지 않았습니다
- 기존 기능은 모두 유지됩니다
- 소셜 로그인은 제외되었습니다 (백엔드 개발자가 구현 예정)
- 모든 API 호출은 에러 처리가 포함되어 있습니다

## 문의사항

통합 과정에서 문제가 발생하면:
1. 백엔드 로그 확인 (`BE` 디렉토리에서 실행 중인 서버 로그)
2. 프론트엔드 로그 확인 (Flutter 콘솔)
3. 네트워크 요청 확인 (브라우저 개발자 도구 또는 Charles Proxy)
