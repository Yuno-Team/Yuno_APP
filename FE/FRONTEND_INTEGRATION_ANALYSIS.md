# Yuno Flutter App - Backend Integration Analysis

## Executive Summary

The Yuno Flutter application is a mobile app for discovering and managing government policies tailored to user profiles. The frontend is currently in a **prototype/mock-data phase** with placeholder API integration points. The backend integration framework is partially established but requires implementation of actual HTTP client calls.

---

## 1. API Service Layer & HTTP Client Configuration

### Current State
- **HTTP Library**: `http: ^1.1.0` (declared in pubspec.yaml)
- **No centralized HTTP client**: There's no custom HTTP client wrapper or interceptor layer implemented
- **No base URL configuration**: No centralized API endpoint configuration exists
- **No authentication headers**: No token/auth header injection mechanism in place

### Service Files Location
- `/FE/lib/services/auth_service.dart` - Authentication service
- `/FE/lib/services/policy_service.dart` - Policy service

### Missing Infrastructure
```
Required but not yet implemented:
- API_CLIENT: Centralized HTTP client with base URL, headers, interceptors
- ERROR_HANDLING: Unified error handling and response parsing
- AUTHENTICATION: Token management and refresh logic
- RETRY_LOGIC: Failed request retry mechanism
- TIMEOUT_CONFIG: Request timeout configuration
- REQUEST_LOGGING: Debug logging for requests/responses
```

---

## 2. Frontend-to-Backend API Calls

### 2.1 Currently Implemented Service Methods

#### PolicyService (lib/services/policy_service.dart)
All methods are currently **mock-based** using hardcoded sample data:

```dart
class PolicyService {
  static final PolicyService _instance = PolicyService._internal();
  factory PolicyService() => _instance;
  
  // Sample data (NOT from backend)
  List<Policy> _samplePolicies = [
    Policy(id: '1', plcyNm: '대학생 창업지원 프로그램', ...),
    Policy(id: '2', plcyNm: '국가우수장학금', ...),
    Policy(id: '3', plcyNm: '청년 주거지원 프로그램', ...),
  ];

  // Current methods (all return mock data):
  Future<List<Policy>> getRecommendedPolicies({List<String> interests}) 
  Future<List<Policy>> getPopularPolicies() 
  Future<List<Policy>> getUpcomingDeadlines() 
  Future<List<Policy>> searchPolicies(String query) 
  Future<bool> bookmarkPolicy(String policyId) 
  Future<bool> unbookmarkPolicy(String policyId) 
}
```

#### AuthService (lib/services/auth_service.dart)
All authentication methods are **stub implementations** without actual backend calls:

```dart
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  // Stub implementations (NOT connected to backend)
  Future<bool> signInWithGoogle()   // TODO: 실제 구글 로그인 구현
  Future<bool> signInWithNaver()    // TODO: 실제 네이버 로그인 구현
  Future<bool> signInWithKakao()    // TODO: 실제 카카오 로그인 구현
  Future<void> signOut() 
  Future<bool> updateUserProfile({...}) 
}
```

### 2.2 API Endpoint Structure (from API_INTEGRATION_GUIDE.md)

#### Policy Search API
```
GET /api/policies/search

Query Parameters:
- query (string, optional): Search term
- mainCategory (string, optional): Main category (일자리, 주거, 교육, 복지문화, 참여권리)
- subCategory (string, optional): Sub category
- policyMethodCode (string, optional): Policy method code
- maritalStatusCode (string, optional): Marital status code
- employmentCode (string, optional): Employment requirement code
- educationCode (string, optional): Education requirement code
- specialRequirementCode (string, optional): Special requirement code
- majorCode (string, optional): Major requirement code
- incomeCode (string, optional): Income condition code
- region (string, optional): Region name

Response:
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

#### Policy Detail API
```
GET /api/policies/{policyId}

Response:
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

#### AI Summary API
```
POST /api/policies/{policyId}/ai-summary

Request Body:
{
  "userProfile": {
    "age": 25,
    "region": "서울",
    "employment": "미취업자",
    "education": "대학 졸업"
  }
}

Response:
{
  "success": true,
  "data": {
    "summary": "이 정책은 ~~을 위한거야...",
    "matchScore": 85,
    "recommendations": ["추천 사항 1", "추천 사항 2"]
  }
}
```

### 2.3 Screens Using API Calls (Current Placeholders)

| Screen | Service Method | Current Status | Location |
|--------|----------------|-----------------|----------|
| HomeScreen | getRecommendedPolicies() | TODO: Mock data | L28: _refreshAiRecommendations() |
| HomeScreen | getPopularPolicies() | Mock data | Hardcoded list |
| HomeScreen | getUpcomingDeadlines() | TODO: Mock data | L99: upcomingSchedules |
| ExploreResultsScreen | searchPolicies() | TODO: Commented out | L96-100 |
| ExploreFilterScreen | searchPolicies() | NOT called | Filter button (L283) |
| PolicyDetailScreen | getPolicyDetail() | Mock search | L39-46 |
| PolicyDetailScreen | getAiSummary() | 2sec delay sim | L65-83 |
| LoginScreen | signInWith* | Stub methods | L136-148 |
| ProfileInputScreen | updateUserProfile() | Stub method | Not shown |

---

## 3. Authentication Flow Between Frontend & Backend

### Current Implementation Status: NOT IMPLEMENTED

#### Auth Service Structure (lib/services/auth_service.dart)
```dart
class AuthService {
  User? _currentUser;
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
}
```

#### Authentication Methods (All Stubs)

1. **Google Sign-In**
   ```dart
   Future<bool> signInWithGoogle() async {
     // TODO: 실제 구글 로그인 구현
     await Future.delayed(Duration(seconds: 1));
     _currentUser = User(
       id: 'google_user_123',
       email: 'user@gmail.com',
       name: '사용자',
       createdAt: DateTime.now(),
     );
     return true;
   }
   ```

2. **Naver Sign-In**
   ```dart
   Future<bool> signInWithNaver() async {
     // TODO: 실제 네이버 로그인 구현
     await Future.delayed(Duration(seconds: 1));
     _currentUser = User(
       id: 'naver_user_123',
       email: 'user@naver.com',
       name: '사용자',
       createdAt: DateTime.now(),
     );
     return true;
   }
   ```

3. **Kakao Sign-In**
   ```dart
   Future<bool> signInWithKakao() async {
     // TODO: 실제 카카오 로그인 구현
     await Future.delayed(Duration(seconds: 1));
     _currentUser = User(
       id: 'kakao_user_123',
       email: 'user@kakao.com',
       name: '사용자',
       createdAt: DateTime.now(),
     );
     return true;
   }
   ```

### Missing Authentication Components

1. **OAuth Flow**: No OAuth client integration (Google, Naver, Kakao SDKs)
2. **Token Management**: 
   - No access token storage
   - No refresh token mechanism
   - No token expiration handling
3. **Session Management**:
   - No persistent login state
   - No session restoration on app restart
4. **API Headers**:
   - No Authorization header injection
   - No Bearer token handling
5. **Error Handling**:
   - No 401/403 error handling
   - No token refresh on 401 response

### Login Screen (lib/screens/login_screen.dart)
```dart
void _handleGoogleLogin(BuildContext context) {
  // TODO: 구글 로그인 로직 구현
  _navigateToNextScreen(context);
}

void _handleNaverLogin(BuildContext context) {
  // TODO: 네이버 로그인 로직 구현
  _navigateToNextScreen(context);
}

void _handleKakaoLogin(BuildContext context) {
  // TODO: 카카오 로그인 로직 구현
  _navigateToNextScreen(context);
}

void _navigateToNextScreen(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => ProfileInputScreen()),
  );
}
```

---

## 4. Data Models & Backend Response Mapping

### 4.1 User Model (lib/models/user.dart)

```dart
class User {
  final String id;
  final String email;
  final String name;
  final DateTime? birthDate;
  final String? region;
  final String? school;
  final String? education;
  final String? major;
  final List<String> interests;
  final DateTime createdAt;

  // JSON Serialization
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      birthDate: json['birthDate'] != null 
          ? DateTime.parse(json['birthDate']) 
          : null,
      region: json['region'],
      school: json['school'],
      education: json['education'],
      major: json['major'],
      interests: List<String>.from(json['interests'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'birthDate': birthDate?.toIso8601String(),
      'region': region,
      'school': school,
      'education': education,
      'major': major,
      'interests': interests,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Copy with method for immutability
  User copyWith({...})
}
```

### 4.2 Policy Model (lib/models/policy.dart)

```dart
class Policy {
  final String id;
  final String plcyNm;              // Policy name
  final String bscPlanPlcyWayNoNm;  // Main category
  final String plcyExplnCn;         // Policy explanation
  final String rgtrupInstCdNm;      // Region
  final String aplyPrdSeCd;         // Application period type
  final String? aplyPrdEndYmd;      // Application deadline (YYYYMMDD)
  final String applicationUrl;
  final List<String> requirements;
  final int saves;
  final bool isBookmarked;

  factory Policy.fromJson(Map<String, dynamic> json) {
    return Policy(
      id: json['id'] ?? '',
      plcyNm: json['plcyNm'] ?? '',
      bscPlanPlcyWayNoNm: json['bscPlanPlcyWayNoNm'] ?? '',
      plcyExplnCn: json['plcyExplnCn'] ?? '',
      rgtrupInstCdNm: json['rgtrupInstCdNm'] ?? '',
      aplyPrdSeCd: json['aplyPrdSeCd'] ?? '',
      aplyPrdEndYmd: json['aplyPrdEndYmd'],
      applicationUrl: json['applicationUrl'] ?? '',
      requirements: List<String>.from(json['requirements'] ?? []),
      saves: json['saves'] ?? 0,
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }

  // Helper getters for convenience
  String get title => plcyNm;
  String get category => bscPlanPlcyWayNoNm;
  String get description => plcyExplnCn;
  String get region => rgtrupInstCdNm;
  String get deadlineDisplay { /* D-Day calculation */ }
}
```

### 4.3 PolicyFilter Model (lib/models/policy_filter.dart)

```dart
class PolicyFilter {
  final String? mainCategory;      // Main category
  final String? subCategory;       // Sub category
  final String? policyMethod;      // Policy method
  final String? maritalStatus;     // Marital status
  final String? employmentStatus;  // Employment status
  final String? educationLevel;    // Education level
  final String? specialRequirement;// Special requirement
  final String? majorRequirement;  // Major requirement
  final String? incomeRequirement; // Income requirement
  final String? region;            // Region

  // Parameter Code Mappings (for API)
  static const Map<String, String> policyMethodCodes = {
    '인프라 구축': '0042001',
    '프로그램': '0042002',
    // ... complete mapping
  };

  // Converts to API format with codes
  Map<String, dynamic> toApiJson() {
    Map<String, dynamic> json = {};
    
    if (policyMethod != null && policyMethodCodes.containsKey(policyMethod)) {
      json['policyMethodCode'] = policyMethodCodes[policyMethod];
    }
    // ... other mappings
    
    return json;
  }
}
```

### 4.4 SavedPolicy Model (lib/models/saved_policy.dart)

```dart
class SavedPolicy {
  final String id;
  final String title;
  final String category;
  final DateTime deadline;
  final String status;
  final bool isToday;

  factory SavedPolicy.fromJson(Map<String, dynamic> json) {
    return SavedPolicy(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      deadline: DateTime.parse(json['deadline']),
      status: json['status'] ?? '',
      isToday: json['isToday'] ?? false,
    );
  }
}
```

---

## 5. State Management & Data Flow

### Current Architecture

The app uses a **simple service pattern** with **local state management** via StatefulWidget:

```
UI (StatefulWidget)
    ↓
Local setState()
    ↓
Service Layer (PolicyService, AuthService)
    ↓
Mock Data / Future Delays
```

### State Management Observations

1. **No Provider/BLoC/Riverpod**: The app declares `provider: ^6.1.1` in pubspec.yaml but doesn't use it
2. **StatefulWidget-based**: Direct setState() calls in screens
3. **No Central State**: Each screen manages its own state independently
4. **No Caching**: No response caching mechanism
5. **No Loading States**: Basic boolean flags for loading states

### Data Flow Examples

#### Example 1: Policy Search (ExploreResultsScreen)
```dart
class _ExploreResultsScreenState extends State<ExploreResultsScreen> {
  String _currentSearchText = '';
  List<Map<String, dynamic>> allPolicies = [/* mock data */];

  // Future API call method (commented out)
  Future<void> _loadPolicies() async {
    // TODO: 백엔드 API 호출
    // final policies = await PolicyService.searchPolicies(
    //   query: widget.searchQuery,
    //   filter: widget.filter,
    // );
  }

  // Filtered data computation
  List<Map<String, dynamic>> get filteredPolicies {
    // Client-side filtering of mock data
    if (widget.filter == null) return allPolicies;
    
    return allPolicies.where((policy) {
      if (widget.filter!.mainCategory != null && 
          policy['category'] != widget.filter!.mainCategory) {
        return false;
      }
      // More filtering logic...
      return true;
    }).toList();
  }
}
```

#### Example 2: Policy Detail Load (PolicyDetailScreen)
```dart
class _PolicyDetailScreenState extends State<PolicyDetailScreen> {
  Policy? _policy;
  bool _isLoading = true;
  final PolicyService _policyService = PolicyService();

  @override
  void initState() {
    super.initState();
    _loadPolicy();
  }

  Future<void> _loadPolicy() async {
    try {
      // Currently searches mock data
      final policies = await _policyService.searchPolicies('');
      final policy = policies.firstWhere(
        (p) => p.id == widget.policyId,
        orElse: () => policies.first,
      );
      
      setState(() {
        _policy = policy;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
```

---

## 6. Hardcoded API Endpoints & Base URLs

### Current Findings

1. **No base URL defined anywhere**
   - No `baseUrl` constant
   - No `API_BASE_URL` environment variable
   - No configuration file

2. **Only hardcoded example URL**
   ```dart
   // In PolicyService._samplePolicies
   applicationUrl: 'https://example.com',
   ```

3. **No environment configuration**
   - No .env file
   - No build flavors for different environments
   - No constants file with API endpoints

4. **API Guide reference** (from API_INTEGRATION_GUIDE.md):
   ```dart
   // From the guide template:
   class PolicyService {
     static const String baseUrl = 'YOUR_API_BASE_URL';
   }
   ```
   - This shows the intended pattern but is NOT implemented

### Missing Configuration Files

```
Needed but not present:
- lib/constants/api_constants.dart
- .env files for environment variables
- lib/config/ folder with environment configs
- Configuration for:
  - API_BASE_URL
  - TIMEOUT_DURATION
  - RETRY_ATTEMPTS
  - LOG_LEVEL
```

---

## 7. Dependencies & Libraries

### pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  provider: ^6.1.1              # Declared but not used
  http: ^1.1.0                   # HTTP client (not integrated)
  shared_preferences: ^2.2.2     # Local storage capability
  url_launcher: ^6.2.2           # External URL opening
```

### Observation
- **http**: Available but no custom client implementation
- **shared_preferences**: Available but not used for token storage
- **provider**: Declared but not utilized for state management

---

## 8. Key Implementation Gaps

### Critical Gaps (Must Implement)

1. **HTTP Client Layer**
   - Create ApiClient with base URL configuration
   - Add request/response logging
   - Implement error handling wrapper

2. **Authentication Integration**
   - Connect to OAuth providers (Google, Naver, Kakao)
   - Implement token storage with SharedPreferences
   - Add token refresh mechanism
   - Handle 401 errors with automatic logout

3. **API Service Implementation**
   - Replace mock data in PolicyService with actual HTTP calls
   - Implement searchPolicies() with backend API
   - Implement getPolicyDetail() with backend API
   - Implement getAiSummary() with backend API

4. **State Management**
   - Consider implementing Provider-based state management
   - Add proper loading/error states
   - Implement data caching layer

5. **Configuration**
   - Create api_constants.dart with base URL
   - Add environment-specific configuration
   - Implement flavor support for dev/prod

### Important Observations

- The API_INTEGRATION_GUIDE.md exists and provides good endpoint documentation
- PolicyFilter has proper code mappings for backend parameters
- Models have proper JSON serialization (fromJson/toJson)
- The foundation is well-structured, just needs HTTP integration

---

## 9. Screen-by-Screen API Integration Points

| Screen | Current Status | Required API Calls | Priority |
|--------|----------------|--------------------|----------|
| LoginScreen | Stub | signIn (OAuth) | Critical |
| ProfileInputScreen | Not analyzed | updateProfile | High |
| HomeScreen | Mock data | getRecommendedPolicies() | High |
| HomeScreen | Mock data | getPopularPolicies() | High |
| HomeScreen | Mock data | getUpcomingDeadlines() | High |
| ExploreEntryScreen | UI only | None (entry point) | Low |
| ExploreFilterScreen | UI only | Pass filters to results | Medium |
| ExploreResultsScreen | Mock data | searchPolicies() | Critical |
| PolicyDetailScreen | Mock search | getPolicyDetail() | Critical |
| PolicyAiSummaryScreen | Template | getAiSummary() | High |
| SavedPoliciesScreen | Not analyzed | getSavedPolicies() | High |
| MyScreen | Not analyzed | getUserProfile() | Medium |

---

## 10. Conclusion & Recommendations

### Current Phase
The Yuno app is in a **prototype/mock-data phase** with:
- Well-designed data models
- Clear API endpoint specifications
- Proper JWT/filter code mappings
- Service layer structure established

### Next Steps (Priority Order)

1. **Phase 1 - Infrastructure** (Week 1)
   - Create `lib/services/api_client.dart` with HTTP client
   - Create `lib/constants/api_constants.dart` with endpoints
   - Implement error handling layer

2. **Phase 2 - Authentication** (Week 2)
   - Integrate OAuth libraries (google_sign_in, flutter_naver_login, kakao_flutter_sdk)
   - Implement token management with SharedPreferences
   - Connect AuthService to actual OAuth providers

3. **Phase 3 - API Integration** (Week 3-4)
   - Replace mock data with API calls in PolicyService
   - Implement search, detail, and AI summary endpoints
   - Add proper loading/error state handling

4. **Phase 4 - State Management** (Week 5)
   - Consider migrating to Provider-based state management
   - Implement caching layer
   - Add offline support

5. **Phase 5 - Testing & Polish** (Week 6+)
   - Add error handling tests
   - Performance optimization
   - User experience improvements

---

## File Structure Summary

```
FE/lib/
├── main.dart                 # App entry point
├── services/
│   ├── auth_service.dart     # Auth (stubs)
│   └── policy_service.dart   # Policy (mocks)
├── models/
│   ├── user.dart            # User model (complete)
│   ├── policy.dart          # Policy model (complete)
│   ├── policy_filter.dart   # Filter model (complete)
│   └── saved_policy.dart    # SavedPolicy model (complete)
├── screens/                  # 18 screen files (mostly UI complete)
└── widgets/                  # Reusable components
```

**Key Files for Backend Integration**:
- `/FE/API_INTEGRATION_GUIDE.md` - API specifications
- `/FE/lib/models/` - All models ready
- `/FE/lib/services/` - Service layer needs HTTP integration
