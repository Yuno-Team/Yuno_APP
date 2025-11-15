# 프론트엔드 개발자에게 전달

**작성일**: 2025-11-13
**AI 담당자** → **프론트엔드 담당자**

---

## 🎯 요약

AI 추천 시스템이 **완성**되었습니다. 프론트엔드에서 **AI 서버를 직접 호출**하여 연동할 수 있습니다.

---

## ✅ 준비 완료 사항

### 1. AI 서버
- **주소**: `http://localhost:8000` (개발)
- **상태**: ✅ 실행 중
- **데이터**: 2,700개 실제 청년 정책
- **CORS**: 설정 완료

### 2. 제공 기능
#### ① 정책 추천 API (BERT 기반)
- **엔드포인트**: `POST /api/recommendations?top_k=3`
- **기능**: 사용자 프로필 기반 맞춤 추천
- **추천 점수**: 0.8+ (매우 높음)
- **응답 시간**: 1초 이내
- **상태**: ✅ **완벽 작동**

#### ② 정책 요약 API (Gemini 기반)
- **엔드포인트**: `POST /api/summary`
- **기능**: 2-3문장 맞춤형 요약
- **상태**: ✅ 코드 정상 (Rate Limit 주의 필요)
- **제한**: 분당 15회 (무료 티어)

---

## 📦 필요한 작업 (프론트엔드)

### Step 1: API 상수 추가 (2분)
**파일**: `lib/constants/api_constants.dart`

```dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:3000';        // 기존 백엔드
  static const String aiBaseUrl = 'http://localhost:8000';      // AI 서버 추가

  // AI 엔드포인트
  static String get aiRecommendations => '$aiBaseUrl/api/recommendations';
  static String get aiSummary => '$aiBaseUrl/api/summary';
}
```

### Step 2: AI 서비스 메서드 추가 (10분)
**파일**: `lib/services/policy_service.dart`

```dart
// AI 추천 정책 가져오기
Future<List<Policy>> getAIRecommendedPolicies({
  required String userId,
  required int age,
  String? major,
  List<String> interests = const [],
  String location = '',
}) async {
  try {
    final response = await _apiClient.post(
      ApiConstants.aiRecommendations,
      data: {
        'user_id': userId,
        'age': age,
        'major': major ?? '',
        'interests': interests,
        'location': location,
      },
      queryParameters: {'top_k': '3'},
    );

    if (response['success'] == true) {
      return (response['data'] as List)
          .map((json) => Policy.fromJson(json))
          .toList();
    }
    return [];
  } catch (e) {
    print('AI 추천 오류: $e');
    return [];
  }
}

// AI 요약 가져오기 (선택)
Future<String> getAISummary({
  required String policyId,
  int? userAge,
  String? userMajor,
  List<String>? userInterests,
}) async {
  try {
    final response = await _apiClient.post(
      ApiConstants.aiSummary,
      data: {
        'policy_id': policyId,
        'user_age': userAge,
        'user_major': userMajor,
        'user_interests': userInterests,
      },
    );

    if (response['success'] == true) {
      return response['summary'];
    }
    return '요약을 생성할 수 없습니다.';
  } catch (e) {
    print('AI 요약 오류: $e');
    return '요약을 생성할 수 없습니다.';
  }
}
```

### Step 3: 홈 화면 수정 (5분)
**파일**: `lib/screens/home_screen.dart`

**83번째 줄 수정**:
```dart
// AS-IS
Future<void> _loadRecommendedPolicies() async {
  // AI 모델 개발 중 - 일단 비워둠
  setState(() {
    aiRecommendedPolicies = [];
    _isLoadingRecommended = false;
  });
}

// TO-BE
Future<void> _loadRecommendedPolicies() async {
  setState(() => _isLoadingRecommended = true);

  try {
    // 사용자 정보 가져오기 (SharedPreferences 등에서)
    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('user_id') ?? 'guest';
    int age = widget.profileData['age'] ?? 25;
    List<String> interests = widget.selectedInterests;

    final policies = await _policyService.getAIRecommendedPolicies(
      userId: userId,
      age: age,
      interests: interests,
      major: widget.profileData['major'],
      location: widget.profileData['region'],
    );

    setState(() {
      aiRecommendedPolicies = policies;
      _isLoadingRecommended = false;
    });
  } catch (e) {
    print('AI 추천 로딩 오류: $e');
    setState(() {
      aiRecommendedPolicies = [];
      _isLoadingRecommended = false;
    });
  }
}
```

---

## 🎯 테스트 방법

### 1. AI 서버 실행 확인
```bash
curl http://localhost:8000/health
```

**기대 응답**:
```json
{
  "status": "healthy",
  "model_loaded": true,
  "total_policies": 2700
}
```

### 2. 추천 API 직접 테스트
```bash
curl -X POST "http://localhost:8000/api/recommendations?top_k=3" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "test_001",
    "age": 24,
    "major": "컴퓨터공학",
    "interests": ["취업", "창업"],
    "location": "서울"
  }'
```

### 3. Flutter 앱에서 테스트
1. 홈 화면 진입
2. "오늘의 AI 추천정책" 섹션 확인
3. 3개 정책이 표시되는지 확인
4. 새로고침 버튼 작동 확인

---

## ⚠️ 주의사항

### 1. Rate Limit (요약 API)
- Gemini 무료 티어: **분당 15회**
- 요약은 사용자가 명시적으로 요청할 때만 호출
- 같은 정책 재요청 시 서버 캐시 활용

### 2. 에러 처리
```dart
try {
  final policies = await getAIRecommendedPolicies(...);
  // 성공 처리
} catch (e) {
  // Fallback: 인기 정책 표시
  print('AI 추천 실패: $e');
}
```

### 3. 로딩 시간
- 첫 요청: 1-2초 (모델 로딩)
- 이후 요청: <100ms (캐시)
- **권장**: 백그라운드 미리 로딩

---

## 📚 참고 자료

### 상세 문서
- **전체 가이드**: `AI/DOCS/FRONTEND_API_GUIDE.md` (440줄)
- Flutter 코드 예시 포함
- 에러 처리 가이드
- 최적화 팁

### API 스펙
```
GET  /health                    - 헬스 체크
POST /api/recommendations       - 정책 추천 (BERT)
POST /api/summary               - 정책 요약 (Gemini)
GET  /api/stats                 - 서버 통계
```

---

## ✅ 예상 작업 시간

| 작업 | 소요 시간 |
|------|-----------|
| API 상수 추가 | 2분 |
| 서비스 메서드 추가 | 10분 |
| 홈 화면 수정 | 5분 |
| 테스트 | 3분 |
| **총계** | **20분** |

---

## 🚀 다음 단계

1. ✅ **지금 가능**: 추천 API 연동
2. 🔄 **나중에**: 요약 API 추가 (선택사항)
3. 📊 **배포 시**: AI 서버 주소만 변경

---

## 💬 문의

AI 서버 관련 질문:
- AI 담당자에게 문의
- 헬스 체크로 서버 상태 확인: `curl http://localhost:8000/health`

---

**준비 완료!** 🎉
바로 연동 시작하셔도 됩니다.
