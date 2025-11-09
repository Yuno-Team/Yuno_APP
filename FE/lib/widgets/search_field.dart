import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final String? hintText;
  final String? value;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onClearPressed;
  final bool enabled;
  final bool showClearButton;

  const SearchField({
    Key? key,
    this.hintText,
    this.value,
    this.onChanged,
    this.onSubmitted,
    this.onClearPressed,
    this.enabled = true,
    this.showClearButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF252931),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 20,
            color: Color(0xFF949CAD),
          ),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              enabled: enabled,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFF6F8FA),
                letterSpacing: -0.8,
                height: 24/16,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText ?? '검색어를 입력하세요...',
                hintStyle: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF949CAD),
                  letterSpacing: -0.8,
                  height: 24/16,
                ),
              ),
            ),
          ),
          if (showClearButton && value?.isNotEmpty == true) ...[
            SizedBox(width: 10),
            GestureDetector(
              onTap: onClearPressed,
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
          ],
        ],
      ),
    );
  }
}
