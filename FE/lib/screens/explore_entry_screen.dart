import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/search_header.dart';
import 'explore_loading_screen.dart';

class ExploreEntryScreen extends StatefulWidget {
  @override
  _ExploreEntryScreenState createState() => _ExploreEntryScreenState();
}

class _ExploreEntryScreenState extends State<ExploreEntryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> recentSearches = [];
  String _currentSearchText = '';
  static const String _recentSearchesKey = 'recent_searches';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  // SharedPreferences에서 최근 검색어 불러오기
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList(_recentSearchesKey) ?? [];
    setState(() {
      recentSearches = searches;
    });
  }

  // SharedPreferences에 최근 검색어 저장
  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, recentSearches);
  }

  void _performSearch(String query) async {
    // 최근 검색어에 추가 (중복 제거)
    setState(() {
      recentSearches.remove(query);
      recentSearches.insert(0, query);
      if (recentSearches.length > 6) {
        recentSearches.removeLast();
      }
    });

    // SharedPreferences에 저장
    await _saveRecentSearches();

    // 로딩 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExploreLoadingScreen(searchQuery: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF111317),
      body: SafeArea(
        child: Column(
          children: [
            // 상태 표시줄 영역 (Figma의 image 5 부분)
            Container(
              height: 32,
              color: Colors.transparent,
            ),
            
            // 검색 헤더
            SearchHeader(
              showBackButton: true,
              showSearchField: true,
              showFilterButton: true,
              searchText: _currentSearchText,
              onSearchChanged: (text) {
                setState(() {
                  _currentSearchText = text;
                  _searchController.text = text;
                });
              },
              onSearchSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  // 검색 실행 - 엔터키나 검색 버튼 클릭 시에만 실행
                  _performSearch(text.trim());
                }
              },
              onBackPressed: () => Navigator.pop(context),
              onFilterPressed: () {
                // 필터 화면으로 이동
                Navigator.pushNamed(context, '/explore_filter');
              },
              onClearPressed: () {
                setState(() {
                  _currentSearchText = '';
                  _searchController.clear();
                });
              },
            ),
            
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 최근 검색 섹션
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '최근 검색',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6A7180),
                          letterSpacing: -0.7,
                          height: 24/14,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    
                    // 최근 검색어 목록
                    Expanded(
                      child: ListView.builder(
                        itemCount: recentSearches.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // 최근 검색어 클릭 시 검색 실행
                                    _performSearch(recentSearches[index]);
                                  },
                                  child: Text(
                                    recentSearches[index],
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: -0.9,
                                      height: 24/18,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 24,
                                  height: 24,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () async {
                                      setState(() {
                                        recentSearches.removeAt(index);
                                      });
                                      // SharedPreferences에서도 삭제
                                      await _saveRecentSearches();
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Color(0xFF6A7180),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: YunoBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          // 네비게이션 처리
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              // 현재 탐색 화면
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
}
