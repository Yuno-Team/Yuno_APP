import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                  // 구글 로그인 버튼
                  _buildSocialLoginButton(
                    iconPath: 'assets/icons/google.svg',
                    text: '구글로 로그인 하기',
                    backgroundColor: Colors.white,
                    textColor: Color(0xFF545454),
                    borderColor: Color(0xFFEBEBEB),
                    onTap: () => _handleGoogleLogin(context),
                  ),
                  
                  SizedBox(height: 8),
                  
                  // 네이버 로그인 버튼
                  _buildSocialLoginButton(
                    iconPath: 'assets/icons/naver.svg',
                    text: '네이버로 로그인 하기',
                    backgroundColor: Color(0xFF03CF5D),
                    textColor: Colors.white,
                    onTap: () => _handleNaverLogin(context),
                  ),
                  
                  SizedBox(height: 8),
                  
                  // 카카오 로그인 버튼
                  _buildSocialLoginButton(
                    iconPath: 'assets/icons/kakao.svg',
                    text: '카카오로 로그인 하기',
                    backgroundColor: Color(0xFFF9E000),
                    textColor: Color(0xFF371C1D),
                    onTap: () => _handleKakaoLogin(context),
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
              SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
              ),
              SizedBox(width: 8),
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
}
