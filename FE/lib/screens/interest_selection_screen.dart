import 'package:flutter/material.dart';
import 'terms_agreement_screen.dart';

class InterestSelectionScreen extends StatefulWidget {
  final Map<String, String>? profileData;

  InterestSelectionScreen({this.profileData});

  @override
  _InterestSelectionScreenState createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  List<String> selectedMainCategories = []; // 대분류 선택
  List<String> selectedSubCategories = []; // 중분류 선택

  // 정책 대분류
  List<String> mainCategories = ['일자리', '주거', '교육', '복지문화', '참여권리'];

  // 정책 중분류 매핑
  Map<String, List<String>> subCategoriesMap = {
    '일자리': ['취업', '재직자', '창업'],
    '주거': ['주택 및 거주지', '기숙사', '전월세 및 주거급여 지원'],
    '교육': ['미래역량강화', '교육비지원', '온라인교육'],
    '복지문화': ['취약계층 및 금융지원', '건강', '예술인지원', '문화활동'],
    '참여권리': ['청년참여', '정책인프라구축', '청년국제교류', '권익보호'],
  };

  // 선택된 대분류들에 해당하는 모든 중분류 목록
  List<String> get currentSubCategories {
    List<String> allSubCategories = [];
    for (String mainCategory in selectedMainCategories) {
      allSubCategories.addAll(subCategoriesMap[mainCategory] ?? []);
    }
    return allSubCategories;
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

            // 헤더 (뒤로가기 버튼 없음)
            Container(
              height: 64,
              padding: EdgeInsets.only(left: 16, right: 16, top: 7, bottom: 7),
              child: Row(
                children: [
                  Text(
                    '관심분야를 선택해주세요.',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF6F8FA),
                      letterSpacing: -0.9,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 관심분야 선택 섹션
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '관심분야를 선택해주세요. (1개 이상)',
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

                        // 대분류 목록 (다중 선택 가능) - 피그마 디자인에 맞게 배치
                        Center(
                          child: Container(
                            width: 239,
                            child: Column(
                              children: [
                                // 첫 번째 줄: 일자리, 주거, 교육
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildCategoryButton('일자리'),
                                    SizedBox(width: 8),
                                    _buildCategoryButton('주거'),
                                    SizedBox(width: 8),
                                    _buildCategoryButton('교육'),
                                  ],
                                ),
                                SizedBox(height: 8),
                                // 두 번째 줄: 복지문화, 참여권리
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildCategoryButton('복지문화'),
                                    SizedBox(width: 8),
                                    _buildCategoryButton('참여권리'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32),

                    // 세부 관심분야 선택 섹션
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '세부 관심분야를 선택해주세요. (3개 이상)',
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

                        // 중분류 목록 (선택된 대분류들의 모든 중분류 표시) - 중앙 정렬
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: currentSubCategories.map((subCategory) {
                            final isSelected = selectedSubCategories.contains(subCategory);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedSubCategories.remove(subCategory);
                                  } else {
                                    selectedSubCategories.add(subCategory);
                                  }
                                });
                              },
                              child: Container(
                                height: 44,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? Color(0xFF193CB8) : Color(0xFF252931),
                                  borderRadius: BorderRadius.circular(56),
                                ),
                                child: Text(
                                  subCategory,
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
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    SizedBox(height: 100), // 버튼 공간 확보
                  ],
                ),
              ),
            ),

            // 다음 버튼 (고정)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: Container(
                height: 56,
                child: ElevatedButton(
                  onPressed: (selectedMainCategories.length >= 1 && selectedSubCategories.length >= 3)
                      ? _goToNext
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (selectedMainCategories.length >= 1 && selectedSubCategories.length >= 3)
                        ? Color(0xFFF6F8FA)
                        : Color(0xFF252931),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '다음으로',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: (selectedMainCategories.length >= 1 && selectedSubCategories.length >= 3)
                          ? Color(0xFF1A1D23)
                          : Color(0xFF6A7180),
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

  Widget _buildCategoryButton(String category) {
    final isSelected = selectedMainCategories.contains(category);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedMainCategories.remove(category);
            // 대분류 제거 시 해당 중분류들도 제거
            List<String> categoriesToRemove = subCategoriesMap[category] ?? [];
            selectedSubCategories.removeWhere((sub) => categoriesToRemove.contains(sub));
          } else {
            selectedMainCategories.add(category);
          }
        });
      },
      child: Container(
        height: 44,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF193CB8) : Color(0xFF252931),
          borderRadius: BorderRadius.circular(56),
        ),
        child: Text(
          category,
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
    );
  }

  void _goToNext() {
    if (selectedMainCategories.length >= 1 && selectedSubCategories.length >= 3) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TermsAgreementScreen(
            selectedInterests: [...selectedMainCategories, ...selectedSubCategories],
            profileData: widget.profileData ?? {},
          ),
        ),
      );
    }
  }
}
