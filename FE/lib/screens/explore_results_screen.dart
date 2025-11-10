import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/search_header.dart';
import '../widgets/policy_card.dart';
import '../models/policy.dart';
import '../models/policy_filter.dart';
import '../services/policy_service.dart';
import 'policy_detail_screen.dart';
import 'explore_filter_screen.dart';
import 'explore_loading_screen.dart';

class ExploreResultsScreen extends StatefulWidget {
  final String searchQuery;
  final PolicyFilter? filter;

  const ExploreResultsScreen({
    Key? key,
    required this.searchQuery,
    this.filter,
  }) : super(key: key);

  @override
  _ExploreResultsScreenState createState() => _ExploreResultsScreenState();
}

class _ExploreResultsScreenState extends State<ExploreResultsScreen> {
  String _currentSearchText = '';
  final PolicyService _policyService = PolicyService();

  List<Policy> allPolicies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentSearchText = widget.searchQuery;
    _loadPolicies();
  }

  Future<void> _loadPolicies() async {
    setState(() => _isLoading = true);
    try {
      final policies = await _policyService.searchPolicies(
        widget.searchQuery,
        filter: widget.filter,
      );
      setState(() {
        allPolicies = policies;
        _isLoading = false;
      });
    } catch (e) {
      print('정책 로딩 오류: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Policy> get filteredPolicies {
    return allPolicies;
    // );
    // setState(() {
    //   allPolicies = policies;
    // });
  }

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
            
            // 검색 헤더
            SearchHeader(
              showBackButton: true,
              showSearchField: true,
              showFilterButton: true,
              searchText: _currentSearchText,
              onBackPressed: () => Navigator.pop(context),
              onSearchChanged: (text) {
                setState(() {
                  _currentSearchText = text;
                });
              },
              onSearchSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  // 새로운 검색 실행 - 로딩 화면으로 이동
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExploreLoadingScreen(searchQuery: text.trim()),
                    ),
                  );
                }
              },
              onClearPressed: () {
                setState(() {
                  _currentSearchText = '';
                });
              },
              onFilterPressed: () {
                // 현재 적용된 필터를 전달
                final currentFilters = <String, dynamic>{};
                if (widget.filter != null) {
                  if (widget.filter!.recentlyAdded == true) {
                    currentFilters['recentlyAdded'] = true;
                  }
                  if (widget.filter!.deadlineImminent == true) {
                    currentFilters['deadlineImminent'] = true;
                  }
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExploreFilterScreen(
                      initialFilters: currentFilters.isEmpty ? null : currentFilters,
                    ),
                  ),
                );
              },
            ),
            
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : filteredPolicies.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Color(0xFF6A7180),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '검색 결과가 없습니다',
                                style: TextStyle(
                                  fontFamily: 'Noto Sans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6A7180),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '다른 조건으로 검색해보세요',
                                style: TextStyle(
                                  fontFamily: 'Noto Sans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF949CAD),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          itemCount: filteredPolicies.length,
                          itemBuilder: (context, index) {
                            final policy = filteredPolicies[index];
                            return PolicyCard(
                              title: policy.title,
                              description: policy.description,
                              category: policy.category,
                              region: policy.region,
                              deadline: policy.deadlineDisplay,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PolicyDetailScreen(
                                      policyId: policy.id,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: YunoBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              // 현재 탐색 화면
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/saved');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/my');
              break;
          }
        },
      ),
    );
  }
}
