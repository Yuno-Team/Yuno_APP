class PolicyFilter {
  final String? mainCategory; // 대분류 (lclsfNm)
  final String? subCategory; // 중분류 (mclsfNm)
  final String? policyMethod; // 정책제공방법
  final String? maritalStatus; // 결혼상태
  final String? employmentStatus; // 취업요건
  final String? educationLevel; // 학력요건
  final String? specialRequirement; // 특화요건
  final String? majorRequirement; // 전공요건
  final String? incomeRequirement; // 소득조건
  final String? region; // 지역

  PolicyFilter({
    this.mainCategory,
    this.subCategory,
    this.policyMethod,
    this.maritalStatus,
    this.employmentStatus,
    this.educationLevel,
    this.specialRequirement,
    this.majorRequirement,
    this.incomeRequirement,
    this.region,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
    if (mainCategory != null && mainCategory != '전체') {
      json['mainCategory'] = mainCategory;
    }
    if (subCategory != null && subCategory != '전체') {
      json['subCategory'] = subCategory;
    }
    if (policyMethod != null && policyMethod != '전체') {
      json['policyMethod'] = policyMethod;
    }
    if (maritalStatus != null && maritalStatus != '제한없음') {
      json['maritalStatus'] = maritalStatus;
    }
    if (employmentStatus != null && employmentStatus != '제한없음') {
      json['employmentStatus'] = employmentStatus;
    }
    if (educationLevel != null && educationLevel != '제한없음') {
      json['educationLevel'] = educationLevel;
    }
    if (specialRequirement != null && specialRequirement != '제한없음') {
      json['specialRequirement'] = specialRequirement;
    }
    if (majorRequirement != null && majorRequirement != '제한없음') {
      json['majorRequirement'] = majorRequirement;
    }
    if (incomeRequirement != null && incomeRequirement != '무관') {
      json['incomeRequirement'] = incomeRequirement;
    }
    if (region != null && region != '지역 선택' && region != '전체') {
      json['region'] = region;
    }
    
    return json;
  }

  factory PolicyFilter.fromJson(Map<String, dynamic> json) {
    return PolicyFilter(
      mainCategory: json['mainCategory'],
      subCategory: json['subCategory'],
      policyMethod: json['policyMethod'],
      maritalStatus: json['maritalStatus'],
      employmentStatus: json['employmentStatus'],
      educationLevel: json['educationLevel'],
      specialRequirement: json['specialRequirement'],
      majorRequirement: json['majorRequirement'],
      incomeRequirement: json['incomeRequirement'],
      region: json['region'],
    );
  }

  PolicyFilter copyWith({
    String? mainCategory,
    String? subCategory,
    String? policyMethod,
    String? maritalStatus,
    String? employmentStatus,
    String? educationLevel,
    String? specialRequirement,
    String? majorRequirement,
    String? incomeRequirement,
    String? region,
  }) {
    return PolicyFilter(
      mainCategory: mainCategory ?? this.mainCategory,
      subCategory: subCategory ?? this.subCategory,
      policyMethod: policyMethod ?? this.policyMethod,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      educationLevel: educationLevel ?? this.educationLevel,
      specialRequirement: specialRequirement ?? this.specialRequirement,
      majorRequirement: majorRequirement ?? this.majorRequirement,
      incomeRequirement: incomeRequirement ?? this.incomeRequirement,
      region: region ?? this.region,
    );
  }

  // 파라미터 코드 매핑을 위한 상수들
  static const Map<String, String> policyMethodCodes = {
    '인프라 구축': '0042001',
    '프로그램': '0042002',
    '직접대출': '0042003',
    '공공기관': '0042004',
    '계약(위탁운영)': '0042005',
    '보조금': '0042006',
    '대출보증': '0042007',
    '공적보험': '0042008',
    '조세지출': '0042009',
    '바우처': '0042010',
    '정보제공': '0042011',
    '경제적 규제': '0042012',
    '기타': '0042013',
  };

  static const Map<String, String> maritalStatusCodes = {
    '기혼': '0055001',
    '미혼': '0055002',
    '제한없음': '0055003',
  };

  static const Map<String, String> incomeCodes = {
    '무관': '0043001',
    '연소득': '0043002',
    '기타': '0043003',
  };

  static const Map<String, String> majorCodes = {
    '인문계열': '0011001',
    '사회계열': '0011002',
    '상경계열': '0011003',
    '이학계열': '0011004',
    '공학계열': '0011005',
    '예체능계열': '0011006',
    '농산업계열': '0011007',
    '기타': '0011008',
    '제한없음': '0011009',
  };

  static const Map<String, String> employmentCodes = {
    '재직자': '0013001',
    '자영업자': '0013002',
    '미취업자': '0013003',
    '프리랜서': '0013004',
    '일용근로자': '0013005',
    '(예비)창업자': '0013006',
    '단기근로자': '0013007',
    '영농종사자': '0013008',
    '기타': '0013009',
    '제한없음': '0013010',
  };

  static const Map<String, String> educationCodes = {
    '고졸 미만': '0049001',
    '고교 재학': '0049002',
    '고졸 예정': '0049003',
    '고교 졸업': '0049004',
    '대학 재학': '0049005',
    '대졸 예정': '0049006',
    '대학 졸업': '0049007',
    '석·박사': '0049008',
    '기타': '0049009',
    '제한없음': '0049010',
  };

  static const Map<String, String> specialRequirementCodes = {
    '중소기업': '0014001',
    '여성': '0014002',
    '기초생활수급자': '0014003',
    '한부모가정': '0014004',
    '장애인': '0014005',
    '농업인': '0014006',
    '군인': '0014007',
    '지역인재': '0014008',
    '기타': '0014009',
    '제한없음': '0014010',
  };

  // 백엔드 API용 파라미터 코드가 포함된 JSON 생성
  Map<String, dynamic> toApiJson() {
    Map<String, dynamic> json = {};
    
    if (policyMethod != null && policyMethodCodes.containsKey(policyMethod)) {
      json['policyMethodCode'] = policyMethodCodes[policyMethod];
    }
    if (maritalStatus != null && maritalStatusCodes.containsKey(maritalStatus)) {
      json['maritalStatusCode'] = maritalStatusCodes[maritalStatus];
    }
    if (incomeRequirement != null && incomeCodes.containsKey(incomeRequirement)) {
      json['incomeCode'] = incomeCodes[incomeRequirement];
    }
    if (majorRequirement != null && majorCodes.containsKey(majorRequirement)) {
      json['majorCode'] = majorCodes[majorRequirement];
    }
    if (employmentStatus != null && employmentCodes.containsKey(employmentStatus)) {
      json['employmentCode'] = employmentCodes[employmentStatus];
    }
    if (educationLevel != null && educationCodes.containsKey(educationLevel)) {
      json['educationCode'] = educationCodes[educationLevel];
    }
    if (specialRequirement != null && specialRequirementCodes.containsKey(specialRequirement)) {
      json['specialRequirementCode'] = specialRequirementCodes[specialRequirement];
    }
    
    // 카테고리는 한글명으로 전달 (백엔드에서 매핑)
    if (mainCategory != null) json['mainCategory'] = mainCategory;
    if (subCategory != null) json['subCategory'] = subCategory;
    if (region != null && region != '지역 선택') json['region'] = region;
    
    return json;
  }
}



