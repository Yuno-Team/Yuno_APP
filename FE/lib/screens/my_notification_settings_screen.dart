import 'package:flutter/material.dart';
import '../widgets/search_header.dart';
import '../widgets/switch_field.dart';

class MyNotificationSettingsScreen extends StatefulWidget {
  @override
  _MyNotificationSettingsScreenState createState() => _MyNotificationSettingsScreenState();
}

class _MyNotificationSettingsScreenState extends State<MyNotificationSettingsScreen> {
  bool _recommendedPolicyNotification = true;
  bool _marketingNotification = false;
  bool _upcomingScheduleNotification = true;

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
                    '알림 설정',
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
            
            Expanded(
              child: Column(
                children: [
                  // 알림 설정 목록
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildNotificationCard(
                          '추천 정책 알림',
                          _recommendedPolicyNotification,
                          (value) {
                            setState(() {
                              _recommendedPolicyNotification = value;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        _buildNotificationCard(
                          '마케팅 알림',
                          _marketingNotification,
                          (value) {
                            setState(() {
                              _marketingNotification = value;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        _buildNotificationCard(
                          '다가오는 일정 알림',
                          _upcomingScheduleNotification,
                          (value) {
                            setState(() {
                              _upcomingScheduleNotification = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  Spacer(),
                  
                  // 저장 버튼 (고정)
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // 저장 기능 구현
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF6F8FA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '저장',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1D23),
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
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(String title, bool value, Function(bool) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF252931),
        borderRadius: BorderRadius.circular(16),
      ),
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
            // 커스텀 토글 스위치
            GestureDetector(
              onTap: () => onChanged(!value),
              child: Container(
                width: 44,
                height: 24,
                decoration: BoxDecoration(
                  color: value ? Color(0xFF165DFB) : Color(0xFF4B515D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedAlign(
                  duration: Duration(milliseconds: 200),
                  alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
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
}
