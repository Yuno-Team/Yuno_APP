import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'policy_ai_summary_screen.dart';
import '../services/policy_service.dart';
import '../services/ai_service.dart';
import '../models/policy.dart';
import '../models/saved_policy.dart';

class PolicyDetailScreen extends StatefulWidget {
  final String policyId;

  const PolicyDetailScreen({
    Key? key,
    required this.policyId,
  }) : super(key: key);

  @override
  _PolicyDetailScreenState createState() => _PolicyDetailScreenState();
}

class _PolicyDetailScreenState extends State<PolicyDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoadingAiSummary = false;
  String? _aiSummaryResult;
  late AnimationController _loadingController;
  bool _isSaved = false; // 저장 상태

  Policy? _policy; // 정책 정보
  bool _isLoading = true; // 정책 로딩 상태
  final PolicyService _policyService = PolicyService();
  static const String _savedPoliciesKey = 'saved_policies';

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _loadPolicy();
    _checkIfSaved();
  }

  // 정책이 이미 저장되어 있는지 확인
  Future<void> _checkIfSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedData = prefs.getString(_savedPoliciesKey);

      if (savedData != null) {
        final List<dynamic> jsonList = json.decode(savedData);
        final savedPolicies = jsonList.map((json) => SavedPolicy.fromJson(json)).toList();

        setState(() {
          _isSaved = savedPolicies.any((policy) => policy.id == widget.policyId);
        });
      }
    } catch (e) {
      print('저장 상태 확인 오류: $e');
    }
  }

  // 정책 저장/삭제 토글
  Future<void> _toggleSave() async {
    if (_policy == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedData = prefs.getString(_savedPoliciesKey);

      List<SavedPolicy> savedPolicies = [];
      if (savedData != null) {
        final List<dynamic> jsonList = json.decode(savedData);
        savedPolicies = jsonList.map((json) => SavedPolicy.fromJson(json)).toList();
      }

      if (_isSaved) {
        // 저장 해제
        savedPolicies.removeWhere((policy) => policy.id == widget.policyId);
      } else {
        // 저장
        // Policy에서 마감일 파싱
        DateTime? deadline;
        try {
          if (_policy!.aplyPrdEndYmd != null && _policy!.aplyPrdEndYmd!.length == 8) {
            final dateStr = _policy!.aplyPrdEndYmd!;
            deadline = DateTime.parse('${dateStr.substring(0, 4)}-${dateStr.substring(4, 6)}-${dateStr.substring(6, 8)}');
          }
        } catch (e) {
          deadline = DateTime.now().add(Duration(days: 30)); // 기본값
        }

        final newSavedPolicy = SavedPolicy(
          id: _policy!.id,
          title: _policy!.title,
          category: _policy!.category,
          deadline: deadline ?? DateTime.now().add(Duration(days: 30)),
          status: '신청마감',
        );

        savedPolicies.insert(0, newSavedPolicy);
      }

      // SharedPreferences에 저장
      final jsonList = savedPolicies.map((policy) => policy.toJson()).toList();
      await prefs.setString(_savedPoliciesKey, json.encode(jsonList));

      setState(() {
        _isSaved = !_isSaved;
      });
    } catch (e) {
      print('정책 저장/삭제 오류: $e');
    }
  }

  Future<void> _loadPolicy() async {
    try {
      final policy = await _policyService.getPolicyDetail(widget.policyId);

      setState(() {
        _policy = policy;
        _isLoading = false;
      });
    } catch (e) {
      print('정책 상세 로딩 오류: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _generateAiSummary() async {
    setState(() {
      _isLoadingAiSummary = true;
      _aiSummaryResult = null;
    });

    _loadingController.repeat();

    try {
      // 사용자 프로필 정보 가져오기
      final prefs = await SharedPreferences.getInstance();

      // 생년월일(YYMMDD)에서 나이 계산
      int? userAge;
      String? birthDate = prefs.getString('birthDate');
      if (birthDate != null && birthDate.length == 6) {
        int birthYear = int.parse(birthDate.substring(0, 2));
        birthYear += (birthYear <= 30) ? 2000 : 1900;
        int currentYear = DateTime.now().year;
        userAge = currentYear - birthYear;
      }

      String? userMajor = prefs.getString('major');

      // 관심사 가져오기
      List<String>? userInterests;
      String? interestsJson = prefs.getString('selected_interests');
      if (interestsJson != null) {
        try {
          userInterests = List<String>.from(jsonDecode(interestsJson));
        } catch (e) {
          print('관심사 파싱 오류: $e');
        }
      }

      // AI 요약 API 호출
      final summary = await AIService.getPolicySummary(
        policyId: widget.policyId,
        userAge: userAge,
        userMajor: userMajor,
        userInterests: userInterests,
      );

      setState(() {
        _isLoadingAiSummary = false;
        if (summary != null && summary.isNotEmpty) {
          _aiSummaryResult = summary;
        } else {
          _aiSummaryResult = 'AI 요약을 생성할 수 없습니다.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingAiSummary = false;
        _aiSummaryResult = '요약 생성 중 오류가 발생했습니다.';
      });
    }

    _loadingController.stop();
    _loadingController.reset();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFF111317),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1447E6),
          ),
        ),
      );
    }

    if (_policy == null) {
      return Scaffold(
        backgroundColor: Color(0xFF111317),
        body: Center(
          child: Text(
            '정책을 찾을 수 없습니다.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF111317),
      body: SafeArea(
        child: Column(
          children: [
            // 상태 표시줄 영역
            Container(
              height: 32,
              color: Colors.transparent,
            ),
            
            // 헤더
            Container(
              height: 64,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: Color(0xFFBDC4D0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    
                    // 정책 번호
                    Text(
                      '정책번호  ${widget.policyId}',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4B515D),
                        letterSpacing: -0.6,
                        height: 14/12,
                      ),
                    ),
                    SizedBox(height: 8),
                    
                    // 카테고리와 지역 태그
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFF162455),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _policy!.bscPlanPlcyWayNoNm,
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
                        SizedBox(width: 6),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFF002D21),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _policy!.rgtrupInstCdNm,
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
                    SizedBox(height: 16),
                    
                    // 정책명과 설명
                    Text(
                      _policy!.plcyNm,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF6F8FA),
                        letterSpacing: -1.2,
                        height: 28/24,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    Text(
                      _policy!.plcyExplnCn,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFBDC4D0),
                        letterSpacing: -0.7,
                        height: 16/14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 16),
                    
                    // AI 요약 버튼/결과
                    _aiSummaryResult != null
                        ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFF1E766F),
                                  Color(0xFF411F86),
                                  Color(0xFF750649),
                                ],
                                stops: [0.0, 0.54, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI 요약',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFBDC4D0),
                                    letterSpacing: -0.8,
                                    height: 18/16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _aiSummaryResult!,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFF6F8FA),
                                    letterSpacing: -0.7,
                                    height: 16/14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFF1E766F),
                                  Color(0xFF411F86),
                                  Color(0xFF750649),
                                ],
                                stops: [0.0, 0.54, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoadingAiSummary ? null : _generateAiSummary,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoadingAiSummary
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: RotationTransition(
                                            turns: _loadingController,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'AI 분석 중...',
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: -1.0,
                                            height: 24/20,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'AI 요약',
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: -1.0,
                                        height: 24/20,
                                      ),
                                    ),
                            ),
                          ),
                    SizedBox(height: 24),
                    
                    // 지원내용
                    Container(
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
                            '지원내용',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF6F8FA),
                              letterSpacing: -0.8,
                              height: 18/16,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            _getSupportContent(),
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFBDC4D0),
                              letterSpacing: -0.7,
                              height: 16/14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    
                    // 신청자격
                    _buildSection('신청자격', [
                      _buildInfoRow('연령', _getAgeRequirement()),
                      _buildInfoRow('거주지역', _getRegionDetails()),
                    ]),
                    SizedBox(height: 32),

                    // 신청방법
                    _buildSection('신청방법', [
                      _buildInfoRow('신청절차', _policy!.plcyAplyMthdCn ?? '정보 없음'),
                    ]),
                    SizedBox(height: 16),

                    // 기타
                    _buildSection('기타', [
                      _buildInfoRow('주관기관', _policy!.operInstCdNm ?? '정보 없음'),
                    ]),
                    
                    SizedBox(height: 100), // 하단 버튼 공간
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Color(0xFF111317),
        padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 24),
        child: Container(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _toggleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSaved ? Color(0xFF1447E6) : Color(0xFFF6F8FA), // blue/600 색상 적용
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _isSaved ? '저장됨 ✓' : '저장',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _isSaved ? Color(0xFFE1E5EC) : Color(0xFF1A1D23), // gray/100 색상 적용
                letterSpacing: -1.0,
                height: 24/20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF6F8FA),
            letterSpacing: -0.8,
            height: 18/16,
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 1,
          color: Color(0xFF353A44),
        ),
        SizedBox(height: 24),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF949CAD),
                letterSpacing: -0.7,
                height: 16/14,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE1E5EC),
                letterSpacing: -0.7,
                height: 16/14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSupportContent() {
    if (_policy?.plcySprtCn != null && _policy!.plcySprtCn!.isNotEmpty) {
      return _policy!.plcySprtCn!;
    }
    return '지원 내용 정보가 없습니다.';
  }

  String _getRegionDetails() {
    // 지역명을 먼저 확인 (사람이 읽을 수 있는 형태)
    if (_policy?.rgtrupInstCdNm != null && _policy!.rgtrupInstCdNm.isNotEmpty) {
      return _policy!.rgtrupInstCdNm;
    }
    // 지역코드는 백업 옵션 (숫자 코드일 경우)
    if (_policy?.zipCd != null && _policy!.zipCd!.isNotEmpty) {
      return _policy!.zipCd!;
    }
    return '전국';
  }

  String _getAgeRequirement() {
    if (_policy?.sprtTrgtMinAge != null && _policy?.sprtTrgtMaxAge != null) {
      return '만 ${_policy!.sprtTrgtMinAge}세~만 ${_policy!.sprtTrgtMaxAge}세';
    } else if (_policy?.sprtTrgtMinAge != null) {
      return '만 ${_policy!.sprtTrgtMinAge}세 이상';
    } else if (_policy?.sprtTrgtMaxAge != null) {
      return '만 ${_policy!.sprtTrgtMaxAge}세 이하';
    }
    return '제한 없음';
  }
}
