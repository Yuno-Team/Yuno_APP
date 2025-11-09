import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'home_screen.dart';

class CompletionScreen extends StatefulWidget {
  final List<String> selectedInterests;
  final Map<String, String> profileData;

  CompletionScreen({
    required this.selectedInterests,
    required this.profileData,
  });

  @override
  _CompletionScreenState createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> {
  @override
  void initState() {
    super.initState();
    _saveUserProfile();
  }

  // 사용자 프로필 저장
  Future<void> _saveUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 프로필 데이터 저장
      await prefs.setString('user_profile', json.encode(widget.profileData));

      // 관심분야 저장
      await prefs.setStringList('user_interests', widget.selectedInterests);

      print('회원가입 정보 저장 완료');
      print('프로필: ${widget.profileData}');
      print('관심분야: ${widget.selectedInterests}');
    } catch (e) {
      print('회원가입 정보 저장 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 2),
              
              // 완료 메시지
              Text(
                '회원가입이 완료되었습니다',
                style: GoogleFonts.notoSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 60),
              
              // Yuno 로고 이미지
              Image.asset(
                'assets/images/yuno_logo.png',
                height: 120,
                width: 280,
                fit: BoxFit.contain,
              ),
              
              SizedBox(height: 40),
              
              Text(
                '이제 맞춤형 정책 서비스',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 8),
              
              Text(
                '유노를 즐겨보세요!',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              
              Spacer(flex: 3),
              
              // 홈으로 버튼
              Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _goToHome(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '홈으로',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _goToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          selectedInterests: widget.selectedInterests,
          profileData: widget.profileData,
        ),
      ),
      (route) => false,
    );
  }
}
