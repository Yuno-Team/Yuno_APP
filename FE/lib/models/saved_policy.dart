class SavedPolicy {
  final String id;
  final String title;
  final String category;
  final DateTime deadline;
  final String status; // '신청마감', '신청시작', '자료제출마감', '설명회참석' 등
  final bool isToday;

  SavedPolicy({
    required this.id,
    required this.title,
    required this.category,
    required this.deadline,
    required this.status,
    this.isToday = false,
  });

  factory SavedPolicy.fromJson(Map<String, dynamic> json) {
    return SavedPolicy(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      deadline: DateTime.parse(json['deadline']),
      status: json['status'] ?? '',
      isToday: json['isToday'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'deadline': deadline.toIso8601String(),
      'status': status,
      'isToday': isToday,
    };
  }

  String get formattedDate {
    return '${deadline.day}일';
  }

  String get weekday {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[deadline.weekday - 1];
  }

  String get deadlineDisplay {
    try {
      // 한국 시간 기준으로 오늘 날짜 계산 (UTC+9)
      final now = DateTime.now().toLocal();
      // 날짜만 비교 (시간 제거)
      final deadlineOnly = DateTime(deadline.year, deadline.month, deadline.day);
      final nowOnly = DateTime(now.year, now.month, now.day);
      final difference = deadlineOnly.difference(nowOnly).inDays;

      if (difference > 0) {
        return '신청마감 D-$difference';
      } else if (difference == 0) {
        return '신청마감 D-Day';
      } else {
        return '마감';
      }
    } catch (e) {
      return status;
    }
  }
}
