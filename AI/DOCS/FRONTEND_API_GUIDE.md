# AI 추천 API 연동 가이드 (프론트엔드용)

## 📌 목표
홈 화면 "오늘의 AI 추천정책 3개"를 실제 AI 모델로부터 가져오기

---

## 🔌 API 엔드포인트

### 기본 정보
- **개발 환경**: `http://localhost:8000`
- **프로덕션**: `http://43.200.164.71:8000` (배포 후)
- **CORS**: 이미 설정됨 (모든 origin 허용)

---

## 📡 정책 추천 API

### `POST /api/recommendations`

사용자 프로필을 기반으로 맞춤 정책을 추천합니다.

#### 요청 (Request)

```json
{
  "user_id": "user_001",
  "age": 24,
  "major": "컴퓨터공학",
  "interests": ["취업", "창업", "주거지원"],
  "location": "서울"
}
```

**필드 설명:**
- `user_id` (필수): 사용자 ID
- `age` (필수): 나이 (15-39세)
- `major` (선택): 전공 (없으면 빈 문자열)
- `interests` (선택): 관심사 배열 (사용자가 온보딩 시 선택한 키워드)
- `location` (선택): 지역 (없으면 빈 문자열)

**쿼리 파라미터:**
- `top_k` (선택): 추천 개수, 기본값 5, 범위 1-20
  - 예: `/api/recommendations?top_k=3` → 3개만 받기

#### 응답 (Response)

```json
{
  "success": true,
  "user_id": "user_001",
  "timestamp": "2025-11-07T20:42:51.340006",
  "total_recommendations": 3,
  "data": [
    {
      "id": "20240703005400200002",
      "plcyNm": "혁신인재육성 아카데미 운영",
      "bscPlanPlcyWayNoNm": "일자리,일자리",
      "plcyExplnCn": "4차 산업혁명, 인공지능...",
      "rgtrupInstCdNm": "강남구청 일자리정책과",
      "aplyPrdSeCd": "기간",
      "aplyPrdEndYmd": "20240516",
      "applicationUrl": "https://...",
      "requirements": ["만 18세~39세"],
      "saves": 27,
      "isBookmarked": false,
      "support_content": "...",
      "keywords": "nan",
      "category_minor": "취업,재직자",
      "recommendationScore": 0.6238
    },
    {
      "id": "20240719005400200001",
      "plcyNm": "용인 창업아카데미",
      "recommendationScore": 0.6222,
      ...
    },
    {
      "id": "20250908005400211664",
      "plcyNm": "초기 창업기업을 위한...",
      "recommendationScore": 0.6154,
      ...
    }
  ],
  "cached": false
}
```

**응답 필드:**
- `success`: 성공 여부
- `user_id`: 요청한 사용자 ID
- `timestamp`: 추천 생성 시간
- `total_recommendations`: 추천 정책 개수
- `data`: 추천 정책 배열 (점수 높은 순으로 정렬됨)
  - `recommendationScore`: AI 추천 점수 (0~1, 높을수록 적합)
- `cached`: 캐시된 결과인지 여부

---

## 🔧 Flutter 연동 방법

### 1단계: HTTP 패키지 확인
`pubspec.yaml`에 이미 있음:
```yaml
dependencies:
  http: ^1.1.0
```

### 2단계: AI 서비스 생성

`lib/services/ai_service.dart` 파일 생성:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/policy.dart';

class AIService {
  // 개발 환경에서는 localhost, 프로덕션에서는 실제 서버 URL
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
          'major': major ?? '',
          'interests': interests ?? [],
          'location': location ?? '',
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

      throw Exception('Failed to get AI recommendations');
    } catch (e) {
      print('AI Service Error: $e');
      return [];
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
```

### 3단계: 홈 화면 수정

`lib/screens/home_screen.dart` 수정:

**Before (43번째 줄):**
```dart
final List<Policy> aiRecommendedPolicies = [
  Policy(id: '1', plcyNm: '청년일자리 도약장려금', ...),
  Policy(id: '2', plcyNm: '청년희망키움통장', ...),
  Policy(id: '3', plcyNm: '기후동행카드', ...),
];
```

**After:**
```dart
List<Policy> aiRecommendedPolicies = [];
bool isLoadingAI = true;

@override
void initState() {
  super.initState();
  _loadAIRecommendations();
}

Future<void> _loadAIRecommendations() async {
  setState(() => isLoadingAI = true);

  try {
    // 사용자 프로필 정보 가져오기 (SharedPreferences 등에서)
    String userId = 'user_001'; // TODO: 실제 user_id
    int age = 24;               // TODO: 실제 age
    List<String> interests = ['취업', '창업', '주거지원']; // TODO: 온보딩 시 저장한 관심사

    final policies = await AIService.getRecommendations(
      userId: userId,
      age: age,
      interests: interests,
      topK: 3, // 3개만 가져오기
    );

    setState(() {
      aiRecommendedPolicies = policies;
      isLoadingAI = false;
    });
  } catch (e) {
    print('AI 추천 로드 실패: $e');
    setState(() => isLoadingAI = false);
  }
}
```

**UI 부분에서 로딩 상태 처리:**
```dart
// 기존 UI에서 aiRecommendedPolicies 사용하는 부분에
isLoadingAI
  ? Center(child: CircularProgressIndicator())
  : ListView.builder(...)
```

### 4단계: 새로고침 기능 (23번째 줄)

**Before:**
```dart
void _refreshAiRecommendations() {
  if (_refreshCount > 0) {
    setState(() {
      _refreshCount--;
    });
    // TODO: 백엔드에서 새로운 AI 추천 정책을 가져오는 로직
  }
}
```

**After:**
```dart
void _refreshAiRecommendations() {
  if (_refreshCount > 0) {
    setState(() {
      _refreshCount--;
    });
    _loadAIRecommendations(); // AI 추천 다시 불러오기
  }
}
```

---

## 📝 사용자 관심사 매핑

프론트엔드에서 사용자가 온보딩 시 선택한 관심사를 그대로 전달하면 됩니다.

**예시:**
```dart
// 온보딩 화면에서 사용자가 선택한 카테고리
List<String> userInterests = [
  '장학금',
  '취창업',
  '주거지원'
];

// 그대로 AI 서버로 전달
AIService.getRecommendations(
  userId: userId,
  age: age,
  interests: userInterests, // 한글 그대로 OK
);
```

AI 모델이 알아서 한글 키워드를 처리합니다.

---

## 🧪 테스트 방법

### 1. AI 서버 실행 확인
```bash
curl http://localhost:8000/health
```

응답:
```json
{
  "status": "healthy",
  "model_loaded": true,
  "total_policies": 2700,
  "timestamp": "2025-11-07T..."
}
```

### 2. 추천 API 테스트
```bash
curl -X POST http://localhost:8000/api/recommendations?top_k=3 \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "test",
    "age": 24,
    "interests": ["취업", "창업"]
  }'
```

### 3. Flutter 앱에서 테스트
1. AI 서버가 `localhost:8000`에서 실행 중인지 확인
2. Flutter 앱 실행
3. 홈 화면에서 "오늘의 AI 추천정책" 섹션 확인
4. 실제 AI 추천 결과가 표시되는지 확인

---

## ⚠️ 주의사항

### 1. CORS 이슈
- AI 서버에 이미 CORS 설정되어 있음
- 모든 origin 허용 중 (`allow_origins=["*"]`)

### 2. 타임아웃
- 첫 요청은 2-3초 걸릴 수 있음 (BERT 모델 로딩)
- 이후 요청은 캐시되어 빠름 (<100ms)

### 3. 에러 처리
- AI 서버가 꺼져있으면 빈 배열 반환
- 사용자에게 "추천을 불러올 수 없습니다" 메시지 표시

### 4. 프로덕션 배포 시
- `AIService.baseUrl`을 `http://43.200.164.71:8000`으로 변경
- 또는 환경 변수로 관리

---

## 🔄 캐시 동작

- 동일한 사용자 프로필로 요청 시 캐시된 결과 반환
- 캐시 유효기간: 서버 재시작 전까지
- 캐시 초기화: `DELETE http://localhost:8000/api/cache` (관리자용)

---

## 📞 문의

AI 서버 관련 문제 발생 시:
1. AI 서버 로그 확인: `pm2 logs ai-server` (배포 후)
2. 헬스 체크: `curl http://localhost:8000/health`
3. AI 팀에게 문의

---

## ✅ 테스트 결과 (2025-11-13)

### 추천 API 테스트
```bash
# 테스트 요청
POST http://localhost:8000/api/recommendations?top_k=3
{
  "user_id": "test_user_001",
  "age": 24,
  "major": "컴퓨터공학",
  "interests": ["취업", "창업"],
  "location": "서울"
}

# 결과
✅ 성공
- 3개 정책 반환
- 추천 점수: 0.85, 0.84, 0.81 (높은 정확도)
- 응답 시간: ~1초
- 관련성: 매우 높음 (취업/창업 관련 정책)
```

### 요약 API 테스트
```bash
# 상태
✅ 코드 정상 작동 확인
⚠️  Gemini API Rate Limit 주의 (무료 티어: 분당 15회)
```

### 현재 서버 상태
- ✅ AI 서버: localhost:8000 실행 중
- ✅ BERT 모델: 2,700개 정책 로딩 완료
- ✅ Gemini API: 연결 성공
- ✅ 추천 시스템: 정상 작동

---

## ⚠️ 주의사항

### 1. Gemini 요약 API Rate Limit
- **무료 티어 제한**: 분당 15회 요청
- 초과 시 429 에러 발생
- **권장**: 요약은 사용자가 명시적으로 요청할 때만 호출
- 캐싱 적극 활용 (동일 정책 재요청 방지)

### 2. 추천 API 최적화
- 첫 요청 응답 시간: 1-2초
- 캐시된 요청: <100ms
- **권장**: 홈 화면 로드 시 백그라운드에서 미리 불러오기

### 3. 에러 처리 필수
```dart
try {
  final policies = await AIService.getRecommendations(...);
  // 성공 처리
} catch (e) {
  // Fallback: 인기 정책 또는 최근 정책 표시
  print('AI 추천 실패: $e');
}
```

---

**Last Updated**: 2025-11-13
**API Version**: 1.0.0
**Test Status**: ✅ Verified
