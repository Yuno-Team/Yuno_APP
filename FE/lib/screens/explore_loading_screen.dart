import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/search_header.dart';
import '../widgets/loading_skeleton.dart';
import 'explore_results_screen.dart';

class ExploreLoadingScreen extends StatefulWidget {
  final String searchQuery;

  const ExploreLoadingScreen({
    Key? key,
    required this.searchQuery,
  }) : super(key: key);

  @override
  _ExploreLoadingScreenState createState() => _ExploreLoadingScreenState();
}

class _ExploreLoadingScreenState extends State<ExploreLoadingScreen> {
  @override
  void initState() {
    super.initState();
    
    // 2초 후 결과 화면으로 이동
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExploreResultsScreen(searchQuery: widget.searchQuery),
          ),
        );
      }
    });
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
              searchText: widget.searchQuery,
              onBackPressed: () => Navigator.pop(context),
              onClearPressed: () => Navigator.pop(context),
              onFilterPressed: () {
                Navigator.pushNamed(context, '/explore_filter');
              },
            ),
            
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    
                    // 로딩 스켈레톤들
                    LoadingSkeleton(
                      height: 56,
                      borderRadius: 6,
                    ),
                    SizedBox(height: 16),
                    
                    LoadingSkeleton(
                      height: 56,
                      borderRadius: 6,
                    ).copyWith(opacity: 0.7),
                    SizedBox(height: 16),
                    
                    LoadingSkeleton(
                      height: 56,
                      borderRadius: 6,
                    ).copyWith(opacity: 0.5),
                    SizedBox(height: 16),
                    
                    LoadingSkeleton(
                      height: 56,
                      borderRadius: 6,
                    ).copyWith(opacity: 0.3),
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

extension OpacityExtension on Widget {
  Widget copyWith({double? opacity}) {
    return Opacity(
      opacity: opacity ?? 1.0,
      child: this,
    );
  }
}



