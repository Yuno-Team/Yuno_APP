import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/bottom_navigation_bar.dart';
import '../models/saved_policy.dart';
import 'policy_detail_screen.dart';

class SavedPoliciesScreen extends StatefulWidget {
  @override
  _SavedPoliciesScreenState createState() => _SavedPoliciesScreenState();
}

class _SavedPoliciesScreenState extends State<SavedPoliciesScreen> {
  bool isListView = true; // 리스트 보기가 기본값
  DateTime currentMonth = DateTime.now();
  List<SavedPolicy> savedPolicies = [];
  bool _isLoading = true;
  static const String _savedPoliciesKey = 'saved_policies';

  @override
  void initState() {
    super.initState();
    _loadSavedPolicies();
  }

  // SharedPreferences에서 저장된 정책 불러오기
  Future<void> _loadSavedPolicies() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedData = prefs.getString(_savedPoliciesKey);

      if (savedData != null) {
        final List<dynamic> jsonList = json.decode(savedData);
        setState(() {
          savedPolicies = jsonList.map((json) => SavedPolicy.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('저장된 정책 불러오기 오류: $e');
      setState(() => _isLoading = false);
    }
  }

  // 정책 삭제
  Future<void> _removePolicy(String policyId) async {
    try {
      setState(() {
        savedPolicies.removeWhere((policy) => policy.id == policyId);
      });

      final prefs = await SharedPreferences.getInstance();
      final jsonList = savedPolicies.map((policy) => policy.toJson()).toList();
      await prefs.setString(_savedPoliciesKey, json.encode(jsonList));
    } catch (e) {
      print('정책 삭제 오류: $e');
    }
  }

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
            
            // 탭 선택 영역
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Color(0xFF252931),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isListView = true;
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isListView ? Color(0xFF4B515D) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.format_list_bulleted,
                                  size: 20,
                                  color: isListView ? Color(0xFFE1E5EC) : Color(0xFF6A7180),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '리스트 보기',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isListView ? Color(0xFFE1E5EC) : Color(0xFF6A7180),
                                    letterSpacing: -0.8,
                                    height: 18/16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isListView = false;
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: !isListView ? Color(0xFF4B515D) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 20,
                                  color: !isListView ? Color(0xFFE1E5EC) : Color(0xFF6A7180),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '캘린더 보기',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: !isListView ? Color(0xFFE1E5EC) : Color(0xFF6A7180),
                                    letterSpacing: -0.8,
                                    height: 18/16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Expanded(
              child: isListView ? _buildListView() : _buildCalendarView(),
            ),
            
            YunoBottomNavigationBar(
              currentIndex: 2, // 저장 탭 활성화
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushNamed(context, '/home');
                } else if (index == 1) {
                  Navigator.pushNamed(context, '/explore');
                } else if (index == 2) {
                  // 현재 저장 화면
                } else if (index == 3) {
                  Navigator.pushNamed(context, '/my');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (savedPolicies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: Color(0xFF6A7180),
            ),
            SizedBox(height: 16),
            Text(
              '저장된 정책이 없습니다',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6A7180),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '관심있는 정책을 저장해보세요',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF949CAD),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 월 네비게이션
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: Color(0xFF949CAD),
                      size: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Container(
                width: 100, // 고정 너비
                child: Text(
                  '${currentMonth.year}년 ${currentMonth.month}월',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF949CAD),
                    letterSpacing: -0.9,
                    height: 22/18,
                  ),
                ),
              ),
              SizedBox(width: 16),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: Color(0xFF949CAD),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 정책 리스트
        Expanded(
          child: _getGroupedPolicies().isEmpty
              ? Center(
                  child: Text(
                    '이번 달에 저장된 정책이 없습니다',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6A7180),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: _getGroupedPolicies().length,
                  itemBuilder: (context, index) {
                    final group = _getGroupedPolicies()[index];
                    return _buildPolicyGroup(group);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCalendarView() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (savedPolicies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: Color(0xFF6A7180),
            ),
            SizedBox(height: 16),
            Text(
              '저장된 정책이 없습니다',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6A7180),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '관심있는 정책을 저장해보세요',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF949CAD),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 월 네비게이션
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: Color(0xFF949CAD),
                      size: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Container(
                width: 100, // 고정 너비
                child: Text(
                  '${currentMonth.year}년 ${currentMonth.month}월',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF949CAD),
                    letterSpacing: -0.9,
                    height: 22/18,
                  ),
                ),
              ),
              SizedBox(width: 16),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: Color(0xFF949CAD),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 캘린더 그리드
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _buildCalendarGrid(),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.4, // 높이를 더 크게
      ),
      itemCount: 35, // 5주 * 7일
      itemBuilder: (context, index) {
        final dayNumber = index - startingWeekday + 2;
        
        if (dayNumber <= 0 || dayNumber > daysInMonth) {
          // 빈 셀 또는 다른 달의 날짜
          return Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFF353A44), width: 1),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    dayNumber <= 0 
                        ? '${DateTime(currentMonth.year, currentMonth.month, 0).day + dayNumber}'
                        : '${dayNumber - daysInMonth}',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6A7180),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final currentDate = DateTime(currentMonth.year, currentMonth.month, dayNumber);
        final policiesForDay = savedPolicies.where((policy) => 
          policy.deadline.year == currentDate.year &&
          policy.deadline.month == currentDate.month &&
          policy.deadline.day == currentDate.day
        ).toList();
        
        final isToday = currentDate.year == DateTime.now().year &&
                       currentDate.month == DateTime.now().month &&
                       currentDate.day == DateTime.now().day;

        return Container(
          decoration: BoxDecoration(
            color: isToday ? Color(0xFF162455) : Colors.transparent,
            border: Border(
              top: BorderSide(color: Color(0xFF353A44), width: 1),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: isToday
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFF193CB8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE1E5EC),
                          ),
                        ),
                      )
                    : Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: policiesForDay.isEmpty ? Color(0xFF6A7180) : Color(0xFFBDC4D0),
                        ),
                      ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: policiesForDay.take(2).map((policy) =>
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PolicyDetailScreen(policyId: policy.id),
                              ),
                            );
                            // 상세보기에서 돌아왔을 때 데이터 다시 로드
                            _loadSavedPolicies();
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 1),
                            child: Text(
                              policy.title,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFE1E5EC),
                                letterSpacing: -0.19,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<List<SavedPolicy>> _getGroupedPolicies() {
    Map<String, List<SavedPolicy>> grouped = {};
    
    for (var policy in savedPolicies) {
      if (policy.deadline.year == currentMonth.year && 
          policy.deadline.month == currentMonth.month) {
        String key = '${policy.deadline.day}일 ${policy.weekday}';
        if (!grouped.containsKey(key)) {
          grouped[key] = [];
        }
        grouped[key]!.add(policy);
      }
    }
    
    return grouped.values.toList();
  }

  Widget _buildPolicyGroup(List<SavedPolicy> policies) {
    if (policies.isEmpty) return Container();
    
    final firstPolicy = policies.first;
    final isToday = firstPolicy.isToday;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF252931),
          borderRadius: BorderRadius.circular(16),
          border: isToday ? Border.all(color: Color(0xFF0077FF), width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  firstPolicy.formattedDate,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFBDC4D0),
                    letterSpacing: -0.7,
                    height: 16/14,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  firstPolicy.weekday,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFBDC4D0).withOpacity(0.5),
                    letterSpacing: -0.7,
                    height: 16/14,
                  ),
                ),
                if (isToday) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(0xFF1C398E),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '오늘',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEFF6FF),
                        letterSpacing: -0.6,
                        height: 16/12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 12),
            Column(
              children: policies.map((policy) =>
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PolicyDetailScreen(policyId: policy.id),
                        ),
                      );
                      // 상세보기에서 돌아왔을 때 데이터 다시 로드
                      _loadSavedPolicies();
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: policies.indexOf(policy) == policies.length - 1 ? 0 : 4),
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              policy.title,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: -0.8,
                                height: 18/16,
                              ),
                            ),
                          ),
                          Text(
                            policy.deadlineDisplay,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF949CAD),
                              letterSpacing: -0.6,
                              height: 14/12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
