import 'package:flutter/material.dart';
import '../widgets/search_header.dart';

class MyWithdrawalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            
            // 헤더
            Container(
              height: 64,
              padding: EdgeInsets.only(left: 8, right: 16, top: 7, bottom: 7),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: Color(0xFFBDC4D0),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '회원탈퇴',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFBDC4D0),
                      letterSpacing: -0.9,
                    ),
                  ),
                ],
              ),
            ),
            
            // 중앙 컨텐츠
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 이미지
                  Container(
                    width: 175,
                    height: 163,
                    child: Image.asset(
                      'assets/icons/out.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  
                  SizedBox(height: 10),
                  
                  // 제목
                  Text(
                    '탈퇴하시겠습니까?',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF8FAFC),
                      letterSpacing: -0.456,
                      height: 1.5,
                    ),
                  ),
                  
                  SizedBox(height: 10),
                  
                  // 설명
                  Text(
                    '모든 정보는 삭제되며, 되돌릴 수 없습니다.',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF949CAD),
                      letterSpacing: -0.304,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // 회원탈퇴 버튼 (고정)
            Container(
              padding: EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    _showWithdrawalDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE7000B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '회원탈퇴',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFF6F8FA),
                      letterSpacing: -1.0,
                      height: 24/20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF252931),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '회원탈퇴',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          content: Text(
            '정말로 탈퇴하시겠습니까?\n모든 데이터가 삭제되며 복구할 수 없습니다.',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFFBDC4D0),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '취소',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF949CAD),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 회원탈퇴 처리 로직
                _processWithdrawal(context);
              },
              child: Text(
                '탈퇴',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _processWithdrawal(BuildContext context) {
    // 회원탈퇴 처리 후 로그인 화면으로 이동
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }
}
