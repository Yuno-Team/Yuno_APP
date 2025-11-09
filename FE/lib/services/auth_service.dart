import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<bool> signInWithGoogle() async {
    try {
      // TODO: 실제 구글 로그인 구현
      await Future.delayed(Duration(seconds: 1));
      
      _currentUser = User(
        id: 'google_user_123',
        email: 'user@gmail.com',
        name: '사용자',
        createdAt: DateTime.now(),
      );
      
      return true;
    } catch (e) {
      print('Google sign in error: $e');
      return false;
    }
  }

  Future<bool> signInWithNaver() async {
    try {
      // TODO: 실제 네이버 로그인 구현
      await Future.delayed(Duration(seconds: 1));
      
      _currentUser = User(
        id: 'naver_user_123',
        email: 'user@naver.com',
        name: '사용자',
        createdAt: DateTime.now(),
      );
      
      return true;
    } catch (e) {
      print('Naver sign in error: $e');
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
