import 'package:flutter/material.dart';

class SearchHeader extends StatefulWidget {
  final String? title;
  final String? searchText;
  final Function(String)? onSearchChanged;
  final Function(String)? onSearchSubmitted;
  final VoidCallback? onBackPressed;
  final VoidCallback? onFilterPressed;
  final VoidCallback? onClearPressed;
  final bool showBackButton;
  final bool showSearchField;
  final bool showFilterButton;

  const SearchHeader({
    Key? key,
    this.title,
    this.searchText,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onBackPressed,
    this.onFilterPressed,
    this.onClearPressed,
    this.showBackButton = false,
    this.showSearchField = false,
    this.showFilterButton = false,
  }) : super(key: key);

  @override
  _SearchHeaderState createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<SearchHeader> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchText ?? '');
  }

  @override
  void didUpdateWidget(SearchHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchText != oldWidget.searchText) {
      _controller.text = widget.searchText ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Row(
        children: [
          if (widget.showBackButton) ...[
            Container(
              width: 32,
              height: 32,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: widget.onBackPressed,
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Color(0xFFBDC4D0),
                ),
              ),
            ),
            SizedBox(width: 8),
          ],
          
          Expanded(
            child: widget.showSearchField 
              ? Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: _controller.text.isNotEmpty 
                      ? Color(0xFF353A44) 
                      : Color(0xFF252931),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      Icon(
                        Icons.search,
                        size: 20,
                        color: Color(0xFF949CAD),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onChanged: (text) {
                            setState(() {}); // UI 업데이트를 위해 setState 호출
                            if (widget.onSearchChanged != null) {
                              widget.onSearchChanged!(text);
                            }
                          },
                          onSubmitted: (text) {
                            if (widget.onSearchSubmitted != null) {
                              widget.onSearchSubmitted!(text);
                            }
                          },
                          textInputAction: TextInputAction.search,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFF6F8FA),
                            letterSpacing: -0.8,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '정책 검색',
                            hintStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF949CAD),
                              letterSpacing: -0.8,
                            ),
                          ),
                        ),
                      ),
                      if (_controller.text.isNotEmpty) ...[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _controller.clear();
                            });
                            if (widget.onClearPressed != null) {
                              widget.onClearPressed!();
                            }
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Color(0xFF6A7180),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Color(0xFF252931),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ],
                  ),
                )
              : widget.title != null 
                ? Text(
                    widget.title!,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFBDC4D0),
                      letterSpacing: -0.9,
                    ),
                  )
                : SizedBox.shrink(),
          ),
          
          if (widget.showFilterButton) ...[
            SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: widget.onFilterPressed,
                icon: Icon(
                  Icons.tune,
                  size: 24,
                  color: Color(0xFFBDC4D0),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
