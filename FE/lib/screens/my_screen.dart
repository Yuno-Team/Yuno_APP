import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/bottom_navigation_bar.dart';

class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  String _profileName = '신범기';
  int _age = 24;
  String _school = '국민대학교';
  String _region = '서울';
  String _gender = '남성';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? profileJson = prefs.getString('user_profile');

      if (profileJson != null) {
        final Map<String, dynamic> profileData = json.decode(profileJson);

        // 생년월일에서 나이 계산 (YYMMDD 형식)
        int calculatedAge = 24; // 기본값
        if (profileData['birthDate'] != null && profileData['birthDate'].length >= 6) {
          String birthDateStr = profileData['birthDate'];
          int yy = int.parse(birthDateStr.substring(0, 2));
          int fullYear = yy >= 0 && yy <= 25 ? 2000 + yy : 1900 + yy;
          int currentYear = DateTime.now().year;
          calculatedAge = currentYear - fullYear;
        }

        setState(() {
          _profileName = profileData['profileName'] ?? '신범기';
          _age = calculatedAge;
          _school = profileData['school'] ?? '국민대학교';
          _region = profileData['region'] ?? '서울';
          _gender = profileData['gender'] ?? '남성';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('프로필 불러오기 오류: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFF111317),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF6F8FA)),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Color(0xFF111317),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar area
            Container(
              height: 32,
              color: Colors.transparent,
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 프로필 섹션
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: Column(
                        children: [
                          // 프로필 이미지
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Container(
                              width: 97,
                              height: 97,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10000),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF0077FF).withOpacity(0.45),
                                    blurRadius: 44,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10000),
                                child: Stack(
                                  children: [
                                    // 성별에 따른 프로필 이미지
                                    Positioned(
                                      left: 1,
                                      top: 0.98,
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        child: Image.asset(
                                          _gender == '여성'
                                              ? 'assets/icons/woman.png'
                                              : 'assets/icons/man.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 16),
                          
                          // 사용자 정보
                          Column(
                            children: [
                              Text(
                                '$_profileName님',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -1.2,
                                  height: 28/24,
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '만 $_age세',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF6A7180),
                                      letterSpacing: -0.8,
                                      height: 18/16,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '·',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF6A7180),
                                      letterSpacing: -0.8,
                                      height: 18/16,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    _school,
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF6A7180),
                                      letterSpacing: -0.8,
                                      height: 18/16,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '·',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF6A7180),
                                      letterSpacing: -0.8,
                                      height: 18/16,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    _region,
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF6A7180),
                                      letterSpacing: -0.8,
                                      height: 18/16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              // 로그아웃 버튼 (60x32 크기)
                              GestureDetector(
                                onTap: () {
                                  // 로그아웃 처리 후 첫 진입 화면으로 이동
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/',
                                    (route) => false,
                                  );
                                },
                                child: Container(
                                  width: 60,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF4B515D),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '로그아웃',
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFF6F8FA),
                                        letterSpacing: -0.6,
                                        height: 14/12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // 메뉴 섹션
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // 첫 번째 메뉴 그룹
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF252931),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                _buildMenuItem('프로필 수정', () {
                                  Navigator.pushNamed(context, '/my_profile_edit');
                                }),
                                _buildMenuItem('관심분야 수정', () {
                                  Navigator.pushNamed(context, '/my_interests_edit');
                                }),
                                _buildMenuItem('알림 설정', () {
                                  Navigator.pushNamed(context, '/my_notification_settings');
                                }),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: 16),
                          
                          // 두 번째 메뉴 그룹
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF252931),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                _buildMenuItem('이용약관', () {
                                  Navigator.pushNamed(context, '/my_terms');
                                }),
                                _buildMenuItem('회원탈퇴', () {
                                  Navigator.pushNamed(context, '/my_withdrawal');
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 56), // Bottom navigation bar 공간
                  ],
                ),
              ),
            ),
            
            YunoBottomNavigationBar(
              currentIndex: 3, // 마이 탭 활성화
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushNamed(context, '/home');
                } else if (index == 1) {
                  Navigator.pushNamed(context, '/explore');
                } else if (index == 2) {
                  Navigator.pushNamed(context, '/saved');
                } else if (index == 3) {
                  // 현재 마이 화면
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: -0.9,
                height: 22/18,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFFBDC4D0),
            ),
          ],
        ),
      ),
    );
  }
}
