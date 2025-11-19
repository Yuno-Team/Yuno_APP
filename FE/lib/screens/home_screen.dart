import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/bottom_navigation_bar.dart';
import '../models/policy.dart';
import '../models/saved_policy.dart';
import '../models/policy_filter.dart';
import '../services/policy_service.dart';
import '../services/ai_service.dart';
import 'explore_results_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<String> selectedInterests;
  final Map<String, String> profileData;

  HomeScreen({
    required this.selectedInterests,
    required this.profileData,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int _selectedIndex = 0;
  int _refreshCount = 3;

  final PolicyService _policyService = PolicyService();

  List<Policy> aiRecommendedPolicies = [];
  List<Policy> popularPolicies = [];
  List<SavedPolicy> upcomingPolicies = [];
  SavedPolicy? deadlineImminentPolicy; // D-day 또는 D-1 정책

  bool _isLoadingRecommended = true;
  bool _isLoadingPopular = true;
  bool _isLoadingUpcoming = true;

  // 배너용 정책 수
  int recentlyAddedCount = 0;
  int deadlineImminentCount = 0;
  int savedPoliciesCount = 0;

  // 새로고침 아이콘 회전 애니메이션
  AnimationController? _rotationController;
  bool _isHovering = false;

  // didChangeDependencies 중복 호출 방지
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _rotationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _rotationController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 포그라운드로 돌아올 때 데이터 새로고침
      _loadUpcomingPolicies();
      _loadPolicyCounts();
    }
  }

  // 화면이 다시 활성화될 때마다 호출됨 (다른 화면에서 돌아올 때)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 초기 로딩이 완료된 후에만 새로고침 (무한 루프 및 중복 로딩 방지)
    // AI 추천은 관심분야 수정 화면에서 돌아올 때만 새로고침 (home_screen.dart:635-638 참조)
    if (_isInitialized && mounted) {
      _loadUpcomingPolicies();
      _loadPolicyCounts();
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadRecommendedPolicies(),
      _loadPopularPolicies(),
      _loadUpcomingPolicies(),
      _loadPolicyCounts(),
    ]);
    // 초기 로딩 완료 표시
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _loadPolicyCounts() async {
    try {
      final recently = await _policyService.getRecentlyAddedCount();
      final deadline = await _policyService.getDeadlineImminentCount();

      // 저장한 정책 수 가져오기 (SharedPreferences에서)
      final prefs = await SharedPreferences.getInstance();
      final String? savedData = prefs.getString('saved_policies');
      int savedCount = 0;
      if (savedData != null) {
        final List<dynamic> savedList = json.decode(savedData);
        savedCount = savedList.length;
      }

      setState(() {
        recentlyAddedCount = recently;
        deadlineImminentCount = deadline;
        savedPoliciesCount = savedCount;
      });
    } catch (e) {
      print('정책 수 로딩 오류: $e');
    }
  }

  Future<void> _loadRecommendedPolicies() async {
    setState(() => _isLoadingRecommended = true);

    try {
      // 사용자 프로필 정보 가져오기
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('user_id') ?? 'guest';

      // 새로고침할 때마다 다른 추천을 받기 위해 타임스탬프 추가
      userId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';

      // 생년월일(YYMMDD)에서 나이 계산
      int age = 24; // 기본값
      String? birthDate = prefs.getString('birthDate');
      if (birthDate != null && birthDate.length == 6) {
        int birthYear = int.parse(birthDate.substring(0, 2));
        // 2000년대생이면 2000+, 1900년대생이면 1900+
        birthYear += (birthYear <= 30) ? 2000 : 1900;
        int currentYear = DateTime.now().year;
        age = currentYear - birthYear;
      }

      String? major = prefs.getString('major');
      String? location = prefs.getString('region');
      List<String> interests = prefs.getStringList('user_interests') ?? [];

      // AI 추천 API 호출 (더 많은 후보를 요청)
      final policies = await AIService.getRecommendations(
        userId: userId,
        age: age,
        major: major,
        interests: interests,
        location: location,
        topK: 10, // 10개 요청해서 다양성 확보
      );

      // 랜덤하게 3개 선택
      setState(() {
        if (policies.length > 3) {
          // 리스트 복사본을 만들어서 셔플
          final shuffled = List<Policy>.from(policies);
          shuffled.shuffle();
          aiRecommendedPolicies = shuffled.take(3).toList();
        } else {
          aiRecommendedPolicies = policies;
        }
        _isLoadingRecommended = false;
      });
    } catch (e) {
      print('AI 추천 로딩 오류: $e');
      setState(() {
        aiRecommendedPolicies = [];
        _isLoadingRecommended = false;
      });
    }
  }

  Future<void> _loadPopularPolicies() async {
    setState(() => _isLoadingPopular = true);
    try {
      final policies = await _policyService.getPopularPolicies();
      setState(() {
        popularPolicies = policies;
        _isLoadingPopular = false;
      });
    } catch (e) {
      print('인기 정책 로딩 오류: $e');
      setState(() => _isLoadingPopular = false);
    }
  }

  Future<void> _loadUpcomingPolicies() async {
    setState(() => _isLoadingUpcoming = true);
    try {
      // SharedPreferences에서 저장한 정책 불러오기
      final prefs = await SharedPreferences.getInstance();
      final String? savedData = prefs.getString('saved_policies');

      List<SavedPolicy> savedPolicies = [];
      if (savedData != null) {
        final List<dynamic> savedList = json.decode(savedData);
        savedPolicies = savedList.map((item) => SavedPolicy.fromJson(item)).toList();
      }

      // 저장한 정책 중 마감일이 있는 정책만 필터링하고 D-day 계산 (SavedPolicy 모델의 deadlineDisplay 활용)
      List<Map<String, dynamic>> policiesWithDday = [];
      for (var policy in savedPolicies) {
        // deadlineDisplay를 확인하여 D-day가 있는 정책만 필터링
        final deadline = policy.deadlineDisplay;

        if (deadline.contains('D-')) {
          // "신청마감 D-5" 형식에서 숫자 추출
          final match = RegExp(r'D-(\d+)').firstMatch(deadline);
          if (match != null) {
            final dday = int.parse(match.group(1)!);

            // D-0 ~ D-31 범위 내의 정책만 포함
            if (dday >= 0 && dday <= 31) {
              policiesWithDday.add({
                'policy': policy,
                'dday': dday,
              });
            }
          }
        }
      }

      // D-day가 가까운 순으로 정렬 (오름차순)
      policiesWithDday.sort((a, b) => a['dday'].compareTo(b['dday']));

      // 최대 6개만 선택
      final limitedPolicies = policiesWithDday.take(6).map((item) => item['policy'] as SavedPolicy).toList();

      // D-day 또는 D-1 정책 찾기 (배너용)
      SavedPolicy? imminentPolicy;
      for (var item in policiesWithDday) {
        if (item['dday'] == 0 || item['dday'] == 1) {
          imminentPolicy = item['policy'] as SavedPolicy;
          break;
        }
      }

      setState(() {
        deadlineImminentPolicy = imminentPolicy;
        upcomingPolicies = limitedPolicies;
        _isLoadingUpcoming = false;
      });
    } catch (e) {
      setState(() => _isLoadingUpcoming = false);
    }
  }

  void _refreshAiRecommendations() {
    if (_refreshCount > 0) {
      setState(() {
        _refreshCount--;
      });
      _loadRecommendedPolicies();
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

            // 헤더 영역
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/yuno_logo_frame.png',
                    width: 110,
                    height: 32,
                  ),
                ],
              ),
            ),

            // 스크롤 가능한 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),

                          // 오늘의 AI 추천 정책 섹션
                          _buildAiRecommendationSection(),

                          SizedBox(height: 16),

                          // 추천 버튼 영역
                          _buildRecommendationButtons(),

                          // 주요 알림 배너 (위치 이동됨) - 있을 때만 간격 추가
                          if (deadlineImminentPolicy != null) ...[
                            SizedBox(height: 16),
                            _buildNotificationBanner(),
                            SizedBox(height: 16),
                          ],

                          // 배너가 없으면 간격만 추가
                          if (deadlineImminentPolicy == null) SizedBox(height: 16),

                          // 인기 정책 TOP3
                          _buildPopularPoliciesSection(),

                          SizedBox(height: 16),

                          // 새로운 배너 (3칸)
                          _buildPolicyCountsBanner(),

                          SizedBox(height: 16),

                          // 다가오는 일정
                          _buildUpcomingScheduleSection(),

                          SizedBox(height: 16),
                        ],
                      ),
                    ),

                    SizedBox(height: 100), // 하단 여백
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: YunoBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          switch (index) {
            case 0:
              // 현재 홈 화면
              break;
            case 1:
              Navigator.pushNamed(context, '/explore');
              break;
            case 2:
              Navigator.pushNamed(context, '/saved');
              break;
            case 3:
              Navigator.pushNamed(context, '/my');
              break;
          }
        },
      ),
    );
  }

  Widget _buildAiRecommendationSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF252931), // 상단 왼쪽 - 약간 밝은 회색
            Color(0xFF1A202C), // 중간 - 어두운 회색
            Color(0xFF2D1B69), // 하단 오른쪽 - 보라색 톤
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '오늘의 AI 추천 정책',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFF6F8FA).withOpacity(0.5),
                      letterSpacing: -0.8,
                      height: 24/16,
                    ),
                  ),
                ),
                MouseRegion(
                  onEnter: (_) {
                    setState(() => _isHovering = true);
                    _rotationController?.forward(from: 0.0);
                  },
                  onExit: (_) {
                    setState(() => _isHovering = false);
                  },
                  child: GestureDetector(
                    onTap: _refreshAiRecommendations,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        children: [
                          if (_rotationController != null)
                            RotationTransition(
                              turns: _rotationController!,
                              child: Image.asset(
                                'assets/icons/restart.png',
                                width: 12,
                                height: 12,
                              ),
                            )
                          else
                            Image.asset(
                              'assets/icons/restart.png',
                              width: 12,
                              height: 12,
                            ),
                          SizedBox(width: 2),
                          Text(
                            '새로고침  $_refreshCount/3',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            color: Color(0xFF949CAD),
                            letterSpacing: -0.6,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ),
              ],
            ),
          ),

          // AI 추천 정책 리스트
          ...aiRecommendedPolicies.map((policy) => _buildAiPolicyCard(policy)),
        ],
      ),
    );
  }

  Widget _buildAiPolicyCard(Policy policy) {
    return GestureDetector(
      onTap: () async {
        // 해당 정책의 상세 페이지로 이동
        await Navigator.pushNamed(
          context,
          '/policy_detail',
          arguments: policy.id,
        );
        // 정책 상세 화면에서 돌아온 후 다가오는 일정과 저장한 정책 수 새로고침
        await _loadUpcomingPolicies();
        await _loadPolicyCounts();
      },
      child: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  policy.title,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF6F8FA),
                    letterSpacing: -0.9,
                    height: 24/18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  policy.businessPeriodDisplay,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6A7180),
                    letterSpacing: -0.6,
                    height: 14/12,
                  ),
                ),
              ],
            ),
          ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF162455),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    policy.category,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C7FFF),
                      letterSpacing: -0.7,
                      height: 16/14,
                    ),
                  ),
                ),
                SizedBox(width: 2),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF002D21),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    policy.region,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF00D492),
                      letterSpacing: -0.7,
                      height: 16/14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/explore');
            },
            child: Container(
              height: 69,
              decoration: BoxDecoration(
                color: Color(0xFF252931),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 1,
                    bottom: -1.5,
                    child: Image.asset(
                      'assets/icons/search_home.png',
                      width: 64,
                      height: 64,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '내게 맞는',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF949CAD),
                            letterSpacing: -0.6,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '정책 찾기',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF6F8FA),
                            letterSpacing: -0.8,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(context, '/my_interests_edit');
              // 관심분야 수정 후 돌아왔을 때 AI 추천 새로고침
              await _loadRecommendedPolicies();
            },
            child: Container(
              height: 69,
              decoration: BoxDecoration(
                color: Color(0xFF252931),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 1,
                    bottom: -1.5,
                    child: Image.asset(
                      'assets/icons/star_home.png',
                      width: 64,
                      height: 64,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '내 정보 입력하고',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF949CAD),
                            letterSpacing: -0.6,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '맞춤 정책 추천 받기',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF6F8FA),
                            letterSpacing: -0.8,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationBanner() {
    // 호출하는 곳에서 null 체크를 하므로 여기서는 항상 표시
    final policy = deadlineImminentPolicy!;
    final endDate = policy.deadline;
    final now = DateTime.now();
    final difference = endDate.difference(DateTime(now.year, now.month, now.day)).inDays;

    // D-day면 clock.png, D-1이면 calandeer.png
    final iconPath = difference == 0 ? 'assets/icons/clock.png' : 'assets/icons/calandeer.png';
    final message = difference == 0
        ? '오늘 ${policy.title} 신청 마감일이에요!'
        : '${policy.title} 신청 마감이 내일이에요.';

    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(
          context,
          '/policy_detail',
          arguments: policy.id,
        );
        // 정책 상세 화면에서 돌아온 후 다가오는 일정과 저장한 정책 수 새로고침
        await _loadUpcomingPolicies();
        await _loadPolicyCounts();
      },
      child: Container(
        height: 64,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Color(0xFF252931),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 40,
              height: 40,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '신청 마감 임박 안내',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFBDC4D0),
                      letterSpacing: -0.6,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF6F8FA),
                      letterSpacing: -0.8,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularPoliciesSection() {
    if (_isLoadingPopular) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF252931),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF252931),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '인기 정책 TOP3',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF949CAD),
              letterSpacing: -0.8,
            ),
          ),
          SizedBox(height: 8),
          if (popularPolicies.isEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '인기 정책이 없습니다',
                style: TextStyle(color: Color(0xFF949CAD)),
              ),
            )
          else
            ...popularPolicies.map((policy) => _buildPopularPolicyCard(policy)),
        ],
      ),
    );
  }

  Widget _buildPopularPolicyCard(Policy policy) {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(
          context,
          '/policy_detail',
          arguments: policy.id,
        );
        // 정책 상세 화면에서 돌아온 후 다가오는 일정과 저장한 정책 수 새로고침
        await _loadUpcomingPolicies();
        await _loadPolicyCounts();
      },
      child: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                policy.title,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF6F8FA),
                  letterSpacing: -0.9,
                  height: 24/18,
                ),
              ),
            ),
            Row(
              children: [
                Image.asset(
                  'assets/icons/eye.png',
                  width: 16,
                  height: 16,
                ),
                SizedBox(width: 2),
                Text(
                  policy.saves.toString(),
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6A7180),
                    letterSpacing: -0.6,
                    height: 14/12,
                  ),
                ),
                SizedBox(width: 8),
                Image.asset(
                  'assets/icons/bookmark_home.png',
                  width: 16,
                  height: 16,
                ),
                SizedBox(width: 2),
                Text(
                  policy.saves.toString(),
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6A7180),
                    letterSpacing: -0.6,
                    height: 14/12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingScheduleSection() {
    if (_isLoadingUpcoming) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF252931),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF252931),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '다가오는 일정',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF949CAD),
              letterSpacing: -0.8,
            ),
          ),
          SizedBox(height: 8),
          if (upcomingPolicies.isEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '저장한 정책 중 마감 임박한 일정이 없습니다',
                style: TextStyle(color: Color(0xFF949CAD), fontSize: 14),
              ),
            )
          else
            ...upcomingPolicies.take(6).map((policy) => _buildUpcomingScheduleCard(policy)),
        ],
      ),
    );
  }

  Widget _buildUpcomingScheduleCard(SavedPolicy policy) {
    final deadline = policy.deadlineDisplay;
    final isUrgent = deadline.contains('D-') &&
                     int.tryParse(deadline.replaceAll(RegExp(r'[^0-9]'), '')) != null &&
                     int.parse(deadline.replaceAll(RegExp(r'[^0-9]'), '')) <= 7;

    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(
          context,
          '/policy_detail',
          arguments: policy.id,
        );
        // 정책 상세 화면에서 돌아온 후 다가오는 일정과 저장한 정책 수 새로고침
        await _loadUpcomingPolicies();
        await _loadPolicyCounts();
      },
      child: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                policy.title,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF6F8FA),
                  letterSpacing: -0.9,
                  height: 24/18,
                ),
              ),
            ),
            Text(
              deadline,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isUrgent ? Color(0xFFFF6467) : Color(0xFF6A7180),
                letterSpacing: -0.6,
                height: 14/12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 새로운 3칸 배너 (새로 추가된 정책, 신청 마감 임박, 저장한 정책)
  Widget _buildPolicyCountsBanner() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Color(0xFF252931),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 새로 추가된 정책
          Expanded(
            child: GestureDetector(
              onTap: () {
                // 최근 추가 필터 적용된 결과 화면으로 이동
                final filter = PolicyFilter(
                  recentlyAdded: true,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExploreResultsScreen(
                      searchQuery: '',
                      filter: filter,
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '새로 추가된 정책',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFBDC4D0),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${recentlyAddedCount}건',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 구분선
          Container(
            width: 1,
            height: 40,
            color: Color(0xFF4B515D),
          ),
          
          // 신청 마감 임박 정책
          Expanded(
            child: GestureDetector(
              onTap: () {
                // 마감 임박 필터 적용된 결과 화면으로 이동
                final filter = PolicyFilter(
                  deadlineImminent: true,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExploreResultsScreen(
                      searchQuery: '',
                      filter: filter,
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '신청 마감 임박 정책',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFBDC4D0),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${deadlineImminentCount}건',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 구분선
          Container(
            width: 1,
            height: 40,
            color: Color(0xFF4B515D),
          ),
          
          // 저장한 정책
          Expanded(
            child: GestureDetector(
              onTap: () {
                // 저장 탭으로 이동
                Navigator.pushNamed(context, '/saved');
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '저장한 정책',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFBDC4D0),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${savedPoliciesCount}건',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}