import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import 'profile_input_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 17),
          child: Column(
            children: [
              SizedBox(height: 230),
              
              // Yuno 로고 이미지
              Container(
                height: 70,
                width: 269,
                child: Image.asset(
                  'assets/images/yuno_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              
              SizedBox(height: 13),
              
              Text(
                '이런 혜택, 알고 있었어?',
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.38,
                ),
                textAlign: TextAlign.center,
              ),
              
              Spacer(),
              
              // 소셜 로그인 버튼들
              Column(
                children: [
                  // 카카오 로그인 버튼
                  _buildSocialLoginButton(
                    iconPath: 'assets/icons/kakao.svg',
                    text: '카카오로 로그인 하기',
                    backgroundColor: Color(0xFFF9E000),
                    textColor: Color(0xFF371C1D),
                    onTap: () => _handleKakaoLogin(context),
                    isImage: false,
                  ),

                  SizedBox(height: 8),

                  // 애플 로그인 버튼
                  _buildSocialLoginButton(
                    iconPath: 'assets/icons/apple_login.png',
                    text: 'Apple로 로그인 하기',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    borderColor: Color(0xFF3A3A3C),
                    onTap: () => _handleAppleLogin(context),
                    isImage: true,
                  ),

                  SizedBox(height: 16),

                  // 게스트로 시작하기 버튼
                  GestureDetector(
                    onTap: () => _handleGuestLogin(context),
                    child: Text(
                      '게스트로 시작하기',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF949CAD),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF949CAD),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton({
    required String iconPath,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
    required bool isImage,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: borderColor != null 
              ? Border.all(color: borderColor, width: 1)
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isImage
                  ? Image.asset(
                      iconPath,
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        // 이미지 로드 실패 시 기본 애플 아이콘 표시
                        return Icon(
                          Icons.apple,
                          size: 24,
                          color: textColor,
                        );
                      },
                    )
                  : SvgPicture.asset(
                      iconPath,
                      width: 24,
                      height: 24,
                    ),
              SizedBox(width: 10),
              Text(
                text,
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.6, // line-height: 24px / font-size: 15px
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAppleLogin(BuildContext context) async {
    try {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      final authService = AuthService();
      final success = await authService.signInWithApple();

      // 로딩 닫기
      Navigator.of(context).pop();

      if (success) {
        _navigateToNextScreen(context, isGuest: false);
      } else {
        _showErrorDialog(context, 'Apple 로그인에 실패했습니다.');
      }
    } catch (e) {
      // 로딩 닫기
      Navigator.of(context).pop();
      _showErrorDialog(context, 'Apple 로그인 중 오류가 발생했습니다.');
    }
  }

  void _handleKakaoLogin(BuildContext context) {
    // TODO: 카카오 로그인 로직 구현
    _navigateToNextScreen(context, isGuest: false);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF252931),
        title: Text(
          '로그인 실패',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: TextStyle(color: Color(0xFFBDC4D0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '확인',
              style: TextStyle(color: Color(0xFF2C7FFF)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleGuestLogin(BuildContext context) {
    // 게스트 모드로 시작
    _navigateToNextScreen(context, isGuest: true);
  }

  void _navigateToNextScreen(BuildContext context, {required bool isGuest}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileInputScreen(isGuest: isGuest),
      ),
    );
  }
}
