# Yuno 앱 API 연동 가이드

## 개요
이 문서는 Yuno 앱의 탐색 기능과 백엔드 API 연동을 위한 가이드입니다.

## API 엔드포인트

### 1. 정책 검색 API
**URL**: `GET /api/policies/search`

**파라미터**:
- `query` (string, optional): 검색어
- `mainCategory` (string, optional): 대분류 (일자리, 주거, 교육, 복지문화, 참여권리)
- `subCategory` (string, optional): 중분류
- `policyMethodCode` (string, optional): 정책제공방법 코드
- `maritalStatusCode` (string, optional): 결혼상태 코드
- `employmentCode` (string, optional): 취업요건 코드
- `educationCode` (string, optional): 학력요건 코드
- `specialRequirementCode` (string, optional): 특화요건 코드
- `majorCode` (string, optional): 전공요건 코드
- `incomeCode` (string, optional): 소득조건 코드
- `region` (string, optional): 지역명

**응답 형식**:
```json
{
  "success": true,
  "data": [
    {
      "id": "20250522005400210865",
      "plcyNm": "청년일자리 도약장려금",
      "bscPlanPlcyWayNoNm": "복지문화",
      "plcyExplnCn": "기업의 청년고용 확대를 지원하고...",
      "rgtrupInstCdNm": "서울",
      "aplyPrdSeCd": "상시",
      "aplyPrdEndYmd": null,
      "applicationUrl": "https://example.com",
      "requirements": ["만 19세~39세", "서울시 거주자"],
      "saves": 150,
      "isBookmarked": false
    }
  ],
  "total": 10,
  "page": 1,
  "limit": 20
}
```

### 2. 정책 상세 조회 API
**URL**: `GET /api/policies/{policyId}`

**응답 형식**:
```json
{
  "success": true,
  "data": {
    "id": "20250522005400210865",
    "plcyNm": "청년일자리 도약장려금",
    "bscPlanPlcyWayNoNm": "복지문화",
    "plcyExplnCn": "상세 설명...",
    "supportContent": "지원 내용 상세...",
    "applicationRequirements": "신청 자격...",
    "applicationMethod": "신청 방법...",
    "organizationInfo": "주관기관 정보..."
  }
}
```

### 3. AI 요약 생성 API
**URL**: `POST /api/policies/{policyId}/ai-summary`

**요청 본문**:
```json
{
  "userProfile": {
    "age": 25,
    "region": "서울",
    "employment": "미취업자",
    "education": "대학 졸업"
  }
}
```

**응답 형식**:
```json
{
  "success": true,
  "data": {
    "summary": "이 정책은 ~~을 위한거야. (내 정보 기반)한 너에게 딱어울려! 신청하면 좋을 것 같아!",
    "matchScore": 85,
    "recommendations": ["추천 사항 1", "추천 사항 2"]
  }
}
```

## 파라미터 코드 매핑

### 정책제공방법 코드 (0042)
- 0042001: 인프라 구축
- 0042002: 프로그램
- 0042003: 직접대출
- 0042004: 공공기관
- 0042005: 계약(위탁운영)
- 0042006: 보조금
- 0042007: 대출보증
- 0042008: 공적보험
- 0042009: 조세지출
- 0042010: 바우처
- 0042011: 정보제공
- 0042012: 경제적 규제
- 0042013: 기타

### 결혼상태 코드 (0055)
- 0055001: 기혼
- 0055002: 미혼
- 0055003: 제한없음

### 소득조건 코드 (0043)
- 0043001: 무관
- 0043002: 연소득
- 0043003: 기타

### 전공요건 코드 (0011)
- 0011001: 인문계열
- 0011002: 사회계열
- 0011003: 상경계열
- 0011004: 이학계열
- 0011005: 공학계열
- 0011006: 예체능계열
- 0011007: 농산업계열
- 0011008: 기타
- 0011009: 제한없음

### 취업요건 코드 (0013)
- 0013001: 재직자
- 0013002: 자영업자
- 0013003: 미취업자
- 0013004: 프리랜서
- 0013005: 일용근로자
- 0013006: (예비)창업자
- 0013007: 단기근로자
- 0013008: 영농종사자
- 0013009: 기타
- 0013010: 제한없음

### 학력요건 코드 (0049)
- 0049001: 고졸 미만
- 0049002: 고교 재학
- 0049003: 고졸 예정
- 0049004: 고교 졸업
- 0049005: 대학 재학
- 0049006: 대졸 예정
- 0049007: 대학 졸업
- 0049008: 석·박사
- 0049009: 기타
- 0049010: 제한없음

### 특화요건 코드 (0014)
- 0014001: 중소기업
- 0014002: 여성
- 0014003: 기초생활수급자
- 0014004: 한부모가정
- 0014005: 장애인
- 0014006: 농업인
- 0014007: 군인
- 0014008: 지역인재
- 0014009: 기타
- 0014010: 제한없음

## 프론트엔드 연동 포인트

### 1. PolicyService 클래스 생성 필요
```dart
// lib/services/policy_service.dart
class PolicyService {
  static const String baseUrl = 'YOUR_API_BASE_URL';
  
  static Future<List<Policy>> searchPolicies({
    String? query,
    PolicyFilter? filter,
  }) async {
    // API 호출 구현
  }
  
  static Future<Policy> getPolicyDetail(String policyId) async {
    // API 호출 구현
  }
  
  static Future<AiSummary> getAiSummary(String policyId, UserProfile profile) async {
    // API 호출 구현
  }
}
```

### 2. 연동 위치
- **검색 기능**: `ExploreResultsScreen._loadPolicies()` 메서드
- **필터링**: `ExploreFilterScreen` 조회 버튼 클릭 시
- **상세 조회**: `PolicyDetailScreen` 진입 시
- **AI 요약**: `PolicyAiSummaryScreen` 진입 시

### 3. 에러 처리
- 네트워크 에러
- API 응답 에러
- 빈 결과 처리
- 로딩 상태 관리

### 4. 캐싱 고려사항
- 검색 결과 캐싱
- 상세 정보 캐싱
- 이미지 캐싱

## 테스트 데이터
현재 앱에는 목업 데이터가 포함되어 있습니다. API 연동 후 해당 데이터를 실제 API 응답으로 교체하면 됩니다.

## 주의사항
1. 모든 API 호출에는 적절한 에러 처리가 필요합니다.
2. 로딩 상태를 사용자에게 표시해야 합니다.
3. 오프라인 상황에 대한 대비책이 필요합니다.
4. API 응답 시간이 길 경우 사용자 경험을 고려해야 합니다.

## 연락처
API 연동 관련 문의사항이 있으시면 프론트엔드 개발팀으로 연락 주세요.



