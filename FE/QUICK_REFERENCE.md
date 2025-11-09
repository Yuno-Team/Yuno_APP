# Yuno Flutter App - Quick Reference Guide for Backend Integration

## Quick Summary

The Yuno Flutter app frontend is **ready for backend integration** but currently uses **mock data and stub implementations**. All data models are complete, but HTTP client and authentication are not yet implemented.

## Current State at a Glance

| Component | Status | Files | Notes |
|-----------|--------|-------|-------|
| **UI/Screens** | 90% Complete | 18 files | Ready, need to wire up API calls |
| **Data Models** | 100% Complete | 4 models | User, Policy, PolicyFilter, SavedPolicy |
| **API Service** | 0% Complete | auth_service.dart, policy_service.dart | All stub/mock implementations |
| **HTTP Client** | Not Started | Missing | Need to create api_client.dart |
| **OAuth Integration** | 0% Complete | auth_service.dart | No SDK integration yet |
| **Configuration** | 0% Complete | Missing | Need api_constants.dart |
| **State Management** | Partial | Provider package installed but unused | Using local setState() instead |

## 3 Critical Files to Create

### 1. lib/services/api_client.dart (New - Critical)
```dart
// Centralized HTTP client with:
// - Base URL configuration
// - Authorization header injection
// - Error handling
// - Request/response logging
// - Timeout management
// - Retry logic
```

### 2. lib/constants/api_constants.dart (New - Critical)
```dart
// Contains:
// - API_BASE_URL = 'https://your-api.com'
// - Endpoint paths
// - Timeout duration (e.g., 30 seconds)
// - Retry attempts
```

### 3. lib/services/token_manager.dart (New - High Priority)
```dart
// Token storage and management:
// - Save access/refresh tokens to SharedPreferences
// - Retrieve tokens for requests
// - Handle token refresh
// - Clear tokens on logout
```

## 5 Services to Modify

### auth_service.dart (Priority: CRITICAL)
**Current:** All methods are stubs returning hardcoded test data
**Required Changes:**
- Replace `signInWithGoogle()` with real OAuth flow
- Replace `signInWithNaver()` with real OAuth flow
- Replace `signInWithKakao()` with real OAuth flow
- Integrate with TokenManager for token storage
- Implement proper error handling

### policy_service.dart (Priority: CRITICAL)
**Current:** All methods return mock data from `_samplePolicies`
**Required Changes:**
- `searchPolicies()` - Call `GET /api/policies/search` with filters
- Add `getPolicyDetail(String id)` - Call `GET /api/policies/{id}`
- Add `getAiSummary(String id, userProfile)` - Call `POST /api/policies/{id}/ai-summary`
- Keep bookmark methods or move to separate service

### Screens that need updates:
- **LoginScreen** - Wire up auth service calls
- **HomeScreen** - Replace mock with real API calls
- **ExploreResultsScreen** - Uncomment and implement `_loadPolicies()`
- **PolicyDetailScreen** - Replace mock search with real API call
- **ProfileInputScreen** - Implement profile update API call

## API Endpoints to Implement

All documented in `/FE/API_INTEGRATION_GUIDE.md`:

1. **POST /auth/login** (Assumed, not documented)
   - For OAuth token exchange

2. **GET /api/policies/search**
   - Query params: query, mainCategory, subCategory, filters with codes
   - Returns: List of policies

3. **GET /api/policies/{policyId}**
   - Returns: Single policy with full details

4. **POST /api/policies/{policyId}/ai-summary**
   - Body: userProfile with age, region, employment, education
   - Returns: AI summary with match score

## Parameter Code Mappings

**Already implemented in PolicyFilter - ready to use:**
- Policy Method: 0042001-0042013 (인프라 구축, 프로그램, etc.)
- Marital Status: 0055001-0055003 (기혼, 미혼, 제한없음)
- Employment: 0013001-0013010 (재직자, 자영업자, etc.)
- Education: 0049001-0049010 (고졸미만, 대학졸업, etc.)
- Special Requirements: 0014001-0014010 (여성, 장애인, etc.)
- Income: 0043001-0043003 (무관, 연소득, 기타)
- Major: 0011001-0011009 (인문계열, 공학계열, etc.)

Use `PolicyFilter.toApiJson()` to convert to backend format.

## Dependencies Already Available

- `http: ^1.1.0` - Use for HTTP requests
- `shared_preferences: ^2.2.2` - Use for token storage
- `provider: ^6.1.1` - Optional, for state management upgrade

## Dependencies to Add

```yaml
dependencies:
  google_sign_in: ^6.0.0
  flutter_naver_login: ^1.3.0
  kakao_flutter_sdk: ^1.4.0
```

## Implementation Order (Suggested)

### Week 1: Infrastructure
1. Create `api_constants.dart`
2. Create `api_client.dart`
3. Create `token_manager.dart`
4. Add OAuth dependencies

### Week 2: Authentication
5. Implement real OAuth in `auth_service.dart`
6. Add token management
7. Test login flow

### Week 3-4: API Integration
8. Implement `PolicyService.searchPolicies()`
9. Implement `PolicyService.getPolicyDetail()`
10. Implement `PolicyService.getAiSummary()`
11. Update screens to use real API calls

### Week 5: Polish
12. Add error handling
13. Add loading states
14. Add response caching
15. Testing

## File Structure After Integration

```
FE/lib/
├── constants/
│   └── api_constants.dart        [NEW]
├── services/
│   ├── api_client.dart           [NEW]
│   ├── token_manager.dart        [NEW]
│   ├── auth_service.dart         [MODIFY]
│   └── policy_service.dart       [MODIFY]
├── models/
│   ├── user.dart                 [OK - Complete]
│   ├── policy.dart               [OK - Complete]
│   ├── policy_filter.dart        [OK - Complete]
│   └── saved_policy.dart         [OK - Complete]
└── screens/
    ├── login_screen.dart         [MODIFY]
    ├── home_screen.dart          [MODIFY]
    ├── explore_results_screen.dart [MODIFY]
    ├── policy_detail_screen.dart [MODIFY]
    └── ... (other screens)
```

## Testing Checklist

- [ ] HTTP client can make requests to API
- [ ] OAuth flow works for Google
- [ ] OAuth flow works for Naver
- [ ] OAuth flow works for Kakao
- [ ] Tokens are stored correctly
- [ ] Token refresh mechanism works
- [ ] Policy search returns results
- [ ] Policy detail loads correctly
- [ ] AI summary generates successfully
- [ ] 401 errors trigger logout
- [ ] Network errors show user feedback
- [ ] Loading states display properly

## Useful Reference

| Item | Location | Purpose |
|------|----------|---------|
| API Spec | `/FE/API_INTEGRATION_GUIDE.md` | Complete endpoint documentation |
| Models | `/FE/lib/models/` | Ready to use for JSON serialization |
| Services | `/FE/lib/services/` | Skeleton structure in place |
| Sample Data | `/FE/lib/services/policy_service.dart` L9-46 | Reference for data structure |

## Common Pitfalls to Avoid

1. **Forgetting to add Authorization header** - All API calls need Bearer token
2. **Not handling 401 errors** - Token expires, need to refresh or logout
3. **Hardcoding base URL** - Use constants file instead
4. **Ignoring network errors** - Show user-friendly error messages
5. **Forgetting to unsubscribe** - Cancel requests in dispose()
6. **No loading states** - Users don't know if app is working
7. **Mixing services and UI logic** - Keep services clean

## Key Class Relationships

```
LoginScreen
    ↓ calls
AuthService
    ↓ uses
TokenManager
    ↓ stores with
SharedPreferences

HomeScreen/ExploreResults
    ↓ calls
PolicyService
    ↓ uses
ApiClient
    ↓ sends requests to
Backend API
```

## Next Steps

1. **Read** `FRONTEND_INTEGRATION_ANALYSIS.md` - Detailed analysis
2. **Read** `BACKEND_INTEGRATION_SUMMARY.txt` - Visual overview
3. **Create** `lib/constants/api_constants.dart` - Start here!
4. **Create** `lib/services/api_client.dart` - Build HTTP client
5. **Modify** `lib/services/auth_service.dart` - Connect OAuth
6. **Test** with real backend endpoints

## Questions to Clarify with Backend Team

1. What is the actual API base URL?
2. What OAuth provider details (client IDs, secrets)?
3. What is the auth token response format?
4. Are there specific error code conventions?
5. Rate limiting policies?
6. CORS configuration for web?
7. Required headers (User-Agent, Accept, etc.)?
8. Pagination strategy for list endpoints?

---

**Status**: Ready for development  
**Last Updated**: 2024-11-04  
**Estimated Implementation Time**: 2-3 weeks
