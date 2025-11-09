import 'package:flutter/material.dart';

class PolicyCard extends StatelessWidget {
  final String title;
  final String description;
  final String category;
  final String region;
  final String deadline;
  final VoidCallback? onTap;

  const PolicyCard({
    Key? key,
    required this.title,
    required this.description,
    required this.category,
    required this.region,
    required this.deadline,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    category,
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
                    region,
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
            SizedBox(height: 8),
            
            // 정책명과 설명
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF6F8FA),
                    letterSpacing: -0.9,
                    height: 24/18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  description,
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
              ],
            ),
            SizedBox(height: 8),
            
            // 마감일
            Text(
              deadline,
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
    );
  }
}



