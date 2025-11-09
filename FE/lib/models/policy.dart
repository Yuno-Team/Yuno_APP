class Policy {
  final String id;
  final String plcyNm; // 정책명
  final String bscPlanPlcyWayNoNm; // 대분류
  final String plcyExplnCn; // 정책 설명
  final String rgtrupInstCdNm; // 지역
  final String aplyPrdSeCd; // 정책기간 상시여부
  final String? aplyPrdEndYmd; // 신청 마감 기한 YYYYMMDD
  final String? bizPrdBgngYmd; // 사업 시작일 YYYYMMDD
  final String? bizPrdEndYmd; // 사업 종료일 YYYYMMDD (실제 마감일)
  final String applicationUrl;
  final List<String> requirements;
  final int saves;
  final bool isBookmarked;

  // 상세 정보 필드 추가
  final String? plcySprtCn; // 지원내용
  final String? plcyAplyMthdCn; // 신청방법
  final String? operInstCdNm; // 운영기관
  final int? sprtTrgtMinAge; // 최소 연령
  final int? sprtTrgtMaxAge; // 최대 연령
  final String? zipCd; // 지역코드
  final String? addAplyQlfcCndCn; // 추가 신청자격

  Policy({
    required this.id,
    required this.plcyNm,
    required this.bscPlanPlcyWayNoNm,
    required this.plcyExplnCn,
    required this.rgtrupInstCdNm,
    required this.aplyPrdSeCd,
    this.aplyPrdEndYmd,
    this.bizPrdBgngYmd,
    this.bizPrdEndYmd,
    required this.applicationUrl,
    required this.requirements,
    this.saves = 0,
    this.isBookmarked = false,
    this.plcySprtCn,
    this.plcyAplyMthdCn,
    this.operInstCdNm,
    this.sprtTrgtMinAge,
    this.sprtTrgtMaxAge,
    this.zipCd,
    this.addAplyQlfcCndCn,
  });

  factory Policy.fromJson(Map<String, dynamic> json) {
    // saves 필드를 int로 변환 (문자열 또는 숫자 모두 처리)
    int parseSaves(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        try {
          return double.parse(value).toInt();
        } catch (e) {
          return 0;
        }
      }
      if (value is double) return value.toInt();
      return 0;
    }

    return Policy(
      id: (json['id'] ?? '').toString(),
      plcyNm: json['plcyNm'] ?? '',
      bscPlanPlcyWayNoNm: json['bscPlanPlcyWayNoNm'] ?? '',
      plcyExplnCn: json['plcyExplnCn'] ?? '',
      rgtrupInstCdNm: json['rgtrupInstCdNm'] ?? '',
      aplyPrdSeCd: json['aplyPrdSeCd'] ?? '',
      aplyPrdEndYmd: json['aplyPrdEndYmd']?.toString(),
      bizPrdBgngYmd: json['bizPrdBgngYmd']?.toString(),
      bizPrdEndYmd: json['bizPrdEndYmd']?.toString(),
      applicationUrl: json['applicationUrl'] ?? '',
      requirements: json['requirements'] != null
          ? List<String>.from(json['requirements'])
          : [],
      saves: parseSaves(json['saves']),
      isBookmarked: json['isBookmarked'] ?? false,
      plcySprtCn: json['plcySprtCn']?.toString(),
      plcyAplyMthdCn: json['plcyAplyMthdCn']?.toString(),
      operInstCdNm: json['operInstCdNm']?.toString(),
      sprtTrgtMinAge: json['sprtTrgtMinAge'] != null ? int.tryParse(json['sprtTrgtMinAge'].toString()) : null,
      sprtTrgtMaxAge: json['sprtTrgtMaxAge'] != null ? int.tryParse(json['sprtTrgtMaxAge'].toString()) : null,
      zipCd: json['zipCd']?.toString(),
      addAplyQlfcCndCn: json['addAplyQlfcCndCn']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plcyNm': plcyNm,
      'bscPlanPlcyWayNoNm': bscPlanPlcyWayNoNm,
      'plcyExplnCn': plcyExplnCn,
      'rgtrupInstCdNm': rgtrupInstCdNm,
      'aplyPrdSeCd': aplyPrdSeCd,
      'aplyPrdEndYmd': aplyPrdEndYmd,
      'bizPrdBgngYmd': bizPrdBgngYmd,
      'bizPrdEndYmd': bizPrdEndYmd,
      'applicationUrl': applicationUrl,
      'requirements': requirements,
      'saves': saves,
      'isBookmarked': isBookmarked,
    };
  }

  // Helper getters for backward compatibility and convenience
  String get title => plcyNm;
  String get category => bscPlanPlcyWayNoNm;
  String get description => plcyExplnCn;
  String get region => rgtrupInstCdNm;
  
  String get deadlineDisplay {
    if (aplyPrdSeCd == '상시') {
      return '상시';
    } else if (aplyPrdEndYmd != null) {
      // YYYYMMDD 형식을 파싱하여 D-Day 계산
      try {
        final dateStr = aplyPrdEndYmd!;
        // YYYYMMDD 형식을 YYYY-MM-DD로 변환
        final formattedDate = '${dateStr.substring(0, 4)}-${dateStr.substring(4, 6)}-${dateStr.substring(6, 8)}';
        final endDate = DateTime.parse(formattedDate);
        // 한국 시간 기준으로 오늘 날짜 계산 (UTC+9)
        final now = DateTime.now().toLocal();
        // 날짜만 비교 (시간 제거)
        final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
        final nowOnly = DateTime(now.year, now.month, now.day);
        final difference = endDateOnly.difference(nowOnly).inDays;
        return difference > 0 ? '신청마감 D-$difference' : '마감';
      } catch (e) {
        return aplyPrdSeCd;
      }
    }
    return aplyPrdSeCd;
  }
}
