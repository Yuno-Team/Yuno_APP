import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/search_header.dart';
import '../models/policy_filter.dart';
import 'explore_results_screen.dart';

class ExploreFilterScreen extends StatefulWidget {
  @override
  _ExploreFilterScreenState createState() => _ExploreFilterScreenState();
}

class _ExploreFilterScreenState extends State<ExploreFilterScreen> {
  String selectedMainCategory = '일자리';
  String selectedSubCategory = '취업';
  String selectedPolicyMethod = '프로그램';
  String selectedMaritalStatus = '미혼';
  String selectedEmploymentStatus = '자영업자';
  String selectedEducationLevel = '고졸 미만';
  String selectedSpecialRequirement = '중소기업';
  String selectedMajorRequirement = '인문계열';
  String selectedIncomeRequirement = '무관';
  String selectedRegion = '지역 선택';
  bool _isMyConditionsHovered = false;

  // 정책 대분류 (실제 데이터)
  List<String> mainCategories = ['일자리', '주거', '교육', '복지문화', '참여권리'];
  
  // 정책 중분류 매핑
  Map<String, List<String>> subCategoriesMap = {
    '일자리': ['취업', '재직자', '창업'],
    '주거': ['주택 및 거주지', '기숙사', '전월세 및 주거급여 지원'],
    '교육': ['미래역량강화', '교육비지원', '온라인교육'],
    '복지문화': ['취약계층 및 금융지원', '건강', '예술인지원', '문화활동'],
    '참여권리': ['청년참여', '정책인프라구축', '청년국제교류', '권익보호'],
  };
  
  // 정책 제공 방법 (실제 데이터)
  List<String> policyMethods = ['인프라 구축', '프로그램', '직접대출', '공공기관', '계약(위탁운영)', '보조금', '대출보증', '공적보험', '조세지출', '바우처', '정보제공', '경제적 규제', '기타'];
  
  // 결혼 상태
  List<String> maritalStatuses = ['기혼', '미혼', '제한없음'];
  
  // 취업 요건
  List<String> employmentStatuses = ['재직자', '자영업자', '미취업자', '프리랜서', '일용근로자', '(예비)창업자', '단기근로자', '영농종사자', '기타', '제한없음'];
  
  // 학력 요건
  List<String> educationLevels = ['고졸 미만', '고교 재학', '고졸 예정', '고교 졸업', '대학 재학', '대졸 예정', '대학 졸업', '석·박사', '기타', '제한없음'];
  
  // 특화 요건
  List<String> specialRequirements = ['중소기업', '여성', '기초생활수급자', '한부모가정', '장애인', '농업인', '군인', '지역인재', '기타', '제한없음'];
  
  // 전공 요건
  List<String> majorRequirements = ['인문계열', '사회계열', '상경계열', '이학계열', '공학계열', '예체능계열', '농산업계열', '기타', '제한없음'];
  
  // 소득 조건
  List<String> incomeRequirements = ['무관', '연소득', '기타'];

  // 현재 선택된 대분류에 따른 중분류 목록
  List<String> get currentSubCategories => subCategoriesMap[selectedMainCategory] ?? [];

  @override
  Widget build(BuildContext context) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                      SizedBox(width: 8),
                      Text(
                        '상세 필터 설정',
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isMyConditionsHovered = true),
                      onExit: (_) => setState(() => _isMyConditionsHovered = false),
                      child: GestureDetector(
                        onTap: _loadMyConditions,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isMyConditionsHovered 
                                ? Color(0xFF1447E6).withOpacity(0.1) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '내 조건 입력',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _isMyConditionsHovered 
                                  ? Color(0xFF1447E6) 
                                  : Color(0xFFBDC4D0),
                              letterSpacing: -0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection('카테고리', mainCategories, selectedMainCategory, (value) {
                      setState(() {
                        selectedMainCategory = value;
                        // 대분류 변경 시 중분류를 첫 번째 항목으로 초기화
                        if (currentSubCategories.isNotEmpty) {
                          selectedSubCategory = currentSubCategories.first;
                        }
                      });
                    }),
                    
                    SizedBox(height: 24),
                    
                    if (currentSubCategories.isNotEmpty)
                      _buildFilterSection('', currentSubCategories, selectedSubCategory, (value) {
                        setState(() {
                          selectedSubCategory = value;
                        });
                      }, showTitle: false),
                    
                    SizedBox(height: 24),
                    
                    _buildFilterSection('정책 제공 방법', policyMethods, selectedPolicyMethod, (value) {
                      setState(() {
                        selectedPolicyMethod = value;
                      });
                    }),
                    
                    SizedBox(height: 24),
                    
                    _buildFilterSection('결혼 여부', maritalStatuses, selectedMaritalStatus, (value) {
                      setState(() {
                        selectedMaritalStatus = value;
                      });
                    }),
                    
                    SizedBox(height: 24),
                    
                    _buildFilterSection('취업 요건', employmentStatuses, selectedEmploymentStatus, (value) {
                      setState(() {
                        selectedEmploymentStatus = value;
                      });
                    }),
                    
                    SizedBox(height: 24),
                    
                    _buildFilterSection('학력 요건', educationLevels, selectedEducationLevel, (value) {
                      setState(() {
                        selectedEducationLevel = value;
                      });
                    }),
                    
                    SizedBox(height: 24),
                    
                    _buildFilterSection('정책 특화 요건', specialRequirements, selectedSpecialRequirement, (value) {
                      setState(() {
                        selectedSpecialRequirement = value;
                      });
                    }),
                    
                    SizedBox(height: 24),
                    
                    _buildFilterSection('전공 요건', majorRequirements, selectedMajorRequirement, (value) {
                      setState(() {
                        selectedMajorRequirement = value;
                      });
                    }),
                    
                    SizedBox(height: 24),
                    
                    _buildFilterSection('소득 요건', incomeRequirements, selectedIncomeRequirement, (value) {
                      setState(() {
                        selectedIncomeRequirement = value;
                      });
                    }),
                    
                    SizedBox(height: 24),
                    
                    _buildRegionSelector(),
                    
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            // 하단 버튼들
            Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // 초기화 기능
                        setState(() {
                          selectedMainCategory = '일자리';
                          selectedSubCategory = '취업';
                          selectedPolicyMethod = '프로그램';
                          selectedMaritalStatus = '미혼';
                          selectedEmploymentStatus = '자영업자';
                          selectedEducationLevel = '고졸 미만';
                          selectedSpecialRequirement = '중소기업';
                          selectedMajorRequirement = '인문계열';
                          selectedIncomeRequirement = '무관';
                          selectedRegion = '지역 선택';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4B515D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '초기화',
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
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // 조회 기능 - 필터 데이터를 결과 화면으로 전달
                        final filter = PolicyFilter(
                          mainCategory: selectedMainCategory,
                          subCategory: selectedSubCategory,
                          policyMethod: selectedPolicyMethod,
                          maritalStatus: selectedMaritalStatus,
                          employmentStatus: selectedEmploymentStatus,
                          educationLevel: selectedEducationLevel,
                          specialRequirement: selectedSpecialRequirement,
                          majorRequirement: selectedMajorRequirement,
                          incomeRequirement: selectedIncomeRequirement,
                          region: selectedRegion == '지역 선택' ? null : selectedRegion,
                        );
                        
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExploreResultsScreen(
                              searchQuery: '필터 검색',
                              filter: filter,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF6F8FA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '조회',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options, String selectedValue, Function(String) onChanged, {bool showTitle = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6A7180),
              letterSpacing: -0.8,
              height: 18/16,
            ),
          ),
          SizedBox(height: 16),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: Row(
            children: options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = option == selectedValue;
              
              return Container(
                margin: EdgeInsets.only(
                  right: index < options.length - 1 ? 9 : 0,
                ),
                child: GestureDetector(
                  onTap: () => onChanged(option),
                  child: Container(
                    height: 44,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(0xFF193CB8) : Color(0xFF252931),
                      borderRadius: BorderRadius.circular(56),
                    ),
                    child: Center(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: isSelected ? 16 : 14,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w600,
                          color: isSelected ? Color(0xFFC3E1FF) : Color(0xFF949CAD),
                          letterSpacing: isSelected ? -0.8 : -0.266,
                          height: 24/16,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRegionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '지역',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6A7180),
            letterSpacing: -0.304,
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(0xFF252931),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Color(0xFF252931)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedRegion == '지역 선택' ? null : selectedRegion,
              hint: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  '지역 선택',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6A7180),
                    height: 24/14,
                  ),
                ),
              ),
              dropdownColor: Color(0xFF252931),
              icon: Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: Color(0xFF949CAD),
                ),
              ),
              items: ['서울', '부산', '대구', '인천', '광주', '대전', '울산', '세종', '경기', '강원', '충북', '충남', '전북', '전남', '경북', '경남', '제주']
                  .map((region) => DropdownMenuItem(
                        value: region,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            region,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFF6F8FA),
                              height: 24/14,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedRegion = value ?? '지역 선택';
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _loadMyConditions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? profileJson = prefs.getString('user_profile');
      final List<String>? interests = prefs.getStringList('user_interests');

      // 기본값 설정
      String loadedRegion = '지역 선택';
      String loadedEducation = '제한없음';
      String loadedMajor = '제한없음';
      String loadedMainCategory = '일자리';
      String loadedSubCategory = '취업';

      // 프로필 데이터에서 불러오기
      if (profileJson != null) {
        final Map<String, dynamic> profileData = json.decode(profileJson);
        loadedRegion = profileData['region'] ?? '지역 선택';
        loadedEducation = profileData['education'] ?? '제한없음';
        loadedMajor = profileData['major'] ?? '제한없음';
      }

      // 관심분야에서 불러오기
      if (interests != null && interests.isNotEmpty) {
        // 첫 번째 관심분야를 사용하여 대분류와 중분류 찾기
        String firstInterest = interests.first;

        // 중분류에서 대분류 역추적
        for (String mainCategory in mainCategories) {
          if (subCategoriesMap[mainCategory]?.contains(firstInterest) ?? false) {
            loadedMainCategory = mainCategory;
            loadedSubCategory = firstInterest;
            break;
          }
        }
      }

      setState(() {
        selectedMainCategory = loadedMainCategory;
        selectedSubCategory = loadedSubCategory;
        selectedEducationLevel = loadedEducation;
        selectedMajorRequirement = loadedMajor;
        selectedRegion = loadedRegion;

        // 기타 조건들은 일반적인 값으로 설정
        selectedPolicyMethod = '기타';
        selectedMaritalStatus = '제한없음';
        selectedEmploymentStatus = '제한없음';
        selectedSpecialRequirement = '제한없음';
        selectedIncomeRequirement = '무관';
      });
    } catch (e) {
      print('내 조건 불러오기 오류: $e');
    }
  }
}
