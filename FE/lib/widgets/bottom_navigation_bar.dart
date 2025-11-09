import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class YunoBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const YunoBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF252931),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border.all(color: Color(0xFF353A44)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Color(0xFFE1E5EC),
        unselectedItemColor: Color(0xFFBDC4D0),
        selectedFontSize: 8,
        unselectedFontSize: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w600,
          height: 1.0,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w600,
          height: 1.0,
          color: Color(0xFFBDC4D0).withOpacity(0.7),
        ),
        items: [
          BottomNavigationBarItem(
            icon: Container(
              width: 24,
              height: 24,
              child: Image.asset(
                'assets/icons/home.png',
                width: 24,
                height: 24,
                color: currentIndex == 0 ? Color(0xFFE1E5EC) : Color(0xFFBDC4D0).withOpacity(0.7),
              ),
            ),
            activeIcon: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/home.png',
                    width: 24,
                    height: 24,
                    color: Color(0xFFE1E5EC),
                  ),
                  SizedBox(height: 2),
                ],
              ),
            ),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 24,
              height: 24,
              child: Image.asset(
                'assets/icons/search.png',
                width: 24,
                height: 24,
                color: currentIndex == 1 ? Color(0xFFE1E5EC) : Color(0xFFBDC4D0).withOpacity(0.7),
              ),
            ),
            activeIcon: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/search.png',
                    width: 24,
                    height: 24,
                    color: Color(0xFFE1E5EC),
                  ),
                  SizedBox(height: 2),
                ],
              ),
            ),
            label: '탐색',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 24,
              height: 24,
              child: Image.asset(
                'assets/icons/bookmark.png',
                width: 24,
                height: 24,
                color: currentIndex == 2 ? Color(0xFFE1E5EC) : Color(0xFFBDC4D0).withOpacity(0.7),
              ),
            ),
            activeIcon: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/bookmark.png',
                    width: 24,
                    height: 24,
                    color: Color(0xFFE1E5EC),
                  ),
                  SizedBox(height: 2),
                ],
              ),
            ),
            label: '저장',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 24,
              height: 24,
              child: Image.asset(
                'assets/icons/user.png',
                width: 24,
                height: 24,
                color: currentIndex == 3 ? Color(0xFFE1E5EC) : Color(0xFFBDC4D0).withOpacity(0.7),
              ),
            ),
            activeIcon: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/user.png',
                    width: 24,
                    height: 24,
                    color: Color(0xFFE1E5EC),
                  ),
                  SizedBox(height: 2),
                ],
              ),
            ),
            label: '마이',
          ),
        ],
      ),
    );
  }
}



