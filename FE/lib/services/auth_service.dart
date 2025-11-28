import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/user.dart';
import '../constants/api_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<bool> signInWithApple() async {
    try {
      // Apple 로그인 요청
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // identityToken을 백엔드로 전송
      if (credential.identityToken == null) {
        print('Apple identity token is null');
        return false;
      }

      // 백엔드 API 호출 (social-login 엔드포인트 사용)
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/social-login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'provider': 'apple',
          'idToken': credential.identityToken,
          'deviceInfo': {
            'platform': 'ios',
            'loginMethod': 'apple',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // 백엔드 응답 구조에 맞게 파싱
        final userData = data['data']?['user'] ?? data['user'];
        final tokens = data['data']?['tokens'];
        
        _currentUser = User(
          id: userData?['id']?.toString() ?? 'apple_user_${DateTime.now().millisecondsSinceEpoch}',
          email: userData?['email'] ?? credential.email ?? '',
          name: userData?['name'] ?? 
                (credential.givenName != null ? '${credential.familyName ?? ''}${credential.givenName}' : 'Apple 사용자'),
          createdAt: DateTime.now(),
        );
        
        // TODO: 토큰 저장 (SharedPreferences 등)
        // if (tokens != null) {
        //   await _saveTokens(tokens['accessToken'], tokens['refreshToken']);
        // }
        
        return true;
      } else {
        print('Apple sign in failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Apple sign in error: $e');
      return false;
    }
  }

  Future<bool> signInWithKakao() async {
    try {
      // TODO: 실제 카카오 로그인 구현
      await Future.delayed(Duration(seconds: 1));
      
      _currentUser = User(
        id: 'kakao_user_123',
        email: 'user@kakao.com',
        name: '사용자',
        createdAt: DateTime.now(),
      );
      
      return true;
    } catch (e) {
      print('Kakao sign in error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
  }

  Future<bool> updateUserProfile({
    DateTime? birthDate,
    String? region,
    String? school,
    String? education,
    String? major,
    List<String>? interests,
  }) async {
    try {
      if (_currentUser == null) return false;
      
      _currentUser = _currentUser!.copyWith(
        birthDate: birthDate,
        region: region,
        school: school,
        education: education,
        major: major,
        interests: interests,
      );
      
      return true;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }
}
