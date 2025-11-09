# Yuno - AI 기반 맞춤형 정책 추천 서비스

## 📱 프로젝트 개요

Yuno는 AI 기반으로 사용자에게 맞춤형 정책을 추천해주는 Flutter 모바일 애플리케이션입니다.

## 🎯 주요 기능

### 1. 사용자 온보딩
- **스플래시 화면**: Yuno 브랜딩과 로딩 애니메이션
- **소셜 로그인**: Google, Naver, Kakao 로그인 지원
- **관심 분야 선택**: 7개 카테고리 중 3개 이상 선택
- **프로필 정보 입력**: 개인정보 및 학력 정보 입력

### 2. 메인 기능
- **AI 추천 정책**: 사용자 프로필 기반 맞춤 정책 추천
- **인기 정책 TOP3**: 저장 수 기준 인기 정책
- **마감 임박 정책**: 신청 마감이 가까운 정책 안내
- **정책 검색**: 키워드 기반 정책 검색

### 3. 정책 카테고리
- 장학금
- 정부지원사업
- 대외활동
- 대회/연구
- 대학생활
- 주거지원
- 취창업

## 🛠 기술 스택

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **State Management**: Provider
- **UI/UX**: Google Fonts, Material Design
- **Authentication**: 소셜 로그인 (Google, Naver, Kakao)
- **Storage**: SharedPreferences

## 📱 화면 구성

1. **SplashScreen** - 앱 시작 화면
2. **LoginScreen** - 소셜 로그인
3. **InterestSelectionScreen** - 관심 분야 선택
4. **ProfileInputScreen** - 프로필 정보 입력
5. **CompletionScreen** - 회원가입 완료
6. **HomeScreen** - 메인 홈 화면

## 🚀 시작하기

### 1. 프로젝트 클론
```bash
git clone https://github.com/Yuno-Team/FE.git
cd yuno_app
```

### 2. 의존성 설치
```bash
flutter pub get
```

### 3. 앱 실행
```bash
flutter run
```

## 📦 주요 패키지

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0    # 폰트
  flutter_svg: ^2.0.9     # SVG 아이콘
  provider: ^6.1.1        # 상태 관리
  http: ^1.1.0            # API 통신
  shared_preferences: ^2.2.2  # 로컬 저장
  url_launcher: ^6.2.2    # URL 실행
```

## 🎨 디자인 시스템

### 색상
- **Primary Background**: Black (#000000)
- **Secondary Background**: White (#FFFFFF)
- **Text Primary**: White (#FFFFFF)
- **Text Secondary**: Grey (#757575)
- **Accent Colors**:
  - Google: White (#FFFFFF)
  - Naver: Green (#03C75A)
  - Kakao: Yellow (#FFE812)

### 타이포그래피
- **Primary Font**: Noto Sans
- **Logo Font**: Poppins
- **Font Sizes**: 48px (Logo), 24px (Title), 18px (Subtitle), 16px (Body), 14px (Caption)

## 📁 프로젝트 구조

```
lib/
├── main.dart
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── interest_selection_screen.dart
│   ├── profile_input_screen.dart
│   ├── completion_screen.dart
│   └── home_screen.dart
├── models/
│   ├── user.dart
│   └── policy.dart
├── services/
│   ├── auth_service.dart
│   └── policy_service.dart
├── widgets/
└── utils/
```

## 🔮 향후 개발 계획

1. **API 연동**: 실제 정책 데이터 API 연결
2. **소셜 로그인**: 실제 소셜 로그인 SDK 연동
3. **알림 기능**: 마감 임박 정책 푸시 알림
4. **즐겨찾기**: 정책 북마크 및 관리
5. **상세 화면**: 정책 상세 정보 화면
6. **검색 고도화**: 필터 및 정렬 기능

## 📄 라이선스

This project is licensed under the MIT License.

## 👥 개발팀

- **UI/UX Designer**: Figma 디자인 시스템 구축
- **Frontend Developer**: Flutter 앱 개발

---
