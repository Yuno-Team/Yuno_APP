import 'package:flutter/material.dart';
import '../widgets/search_header.dart';

class MyTermsScreen extends StatelessWidget {
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
            
            // 헤더
            SearchHeader(
              title: '이용약관',
              showBackButton: true,
              showSearchField: false,
              showFilterButton: false,
              onBackPressed: () => Navigator.pop(context),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 24),
                    
                    // 이용약관 섹션
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '이용약관',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: -0.9,
                              height: 22/18,
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 400,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xFF252931),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                '''본 이용약관은 Yuno(이하 "서비스") 이용과 관련하여 회원과 서비스 운영자 간의 권리·의무 및 책임사항을 규정합니다.

1. 목적

본 약관은 Yuno 서비스 제공 및 이용 조건을 정하는 데 목적이 있습니다.

2. 정의

• "서비스": Yuno 앱 및 관련 웹서비스
• "회원": 서비스에 가입하여 이용하는 자
• "콘텐츠": 정책 정보, 텍스트, 이미지, 데이터 등 서비스에서 제공되는 모든 자료

3. 약관의 효력 및 변경

• 본 약관은 서비스 화면 내 게시 시 효력이 발생합니다.
• 서비스는 필요한 경우 약관을 변경할 수 있으며, 사전 공지 후 시행합니다.
• 변경된 약관에 동의하지 않을 경우 회원은 언제든지 탈퇴할 수 있습니다.

4. 서비스 제공 내용

서비스는 다음 기능을 제공합니다.

• 사용자 조건 기반 정책 추천
• 정책 상세 요약 정보 제공
• 즐겨찾기 기능
• 공공사이트 링크 제공

※ 서비스는 정책 신청을 대행하지 않습니다.

5. 회원가입

회원은 올바른 정보를 입력해야 하며, 허위 정보 제공 시 서비스 이용이 제한될 수 있습니다.

6. 서비스 이용 제한

다음의 경우 서비스 이용을 제한하거나 중지할 수 있습니다.

• 법령 또는 약관 위반
• 서비스 운영 방해
• 부정 이용, 자동화 도구 사용
• 기타 서비스가 부적절하다고 판단하는 경우

7. 회원의 의무

회원은 다음 행위를 해서는 안 됩니다.

• 허위 정보 입력
• 서비스 내 콘텐츠 무단 복제, 배포
• 타인의 개인정보 수집
• 서비스 기능을 악용하거나 공격
• 광고, 스팸, 불법 콘텐츠 게시

8. 서비스의 책임 제한

• 서비스는 정책 정보를 직접 제공하는 기관이 아니며, 정책 정보는 공개된 자료 기반으로 제공됩니다.
• 제공되는 정보는 최신성·정확성을 100% 보장하지 않을 수 있으며, 최종 정보는 반드시 각 정책 기관의 공식 사이트를 확인해야 합니다.

9. 콘텐츠의 저작권

• 서비스에서 제공하는 콘텐츠의 저작권은 서비스 또는 해당 콘텐츠 제공자에게 있습니다.
• 회원은 서비스 콘텐츠를 무단 복제·배포할 수 없습니다.

10. 회원탈퇴

• 회원은 언제든지 앱 내 기능을 통해 탈퇴할 수 있습니다.
• 탈퇴 시 모든 개인정보는 즉시 삭제됩니다.

11. 분쟁 해결

서비스는 이용자의 불만 해결을 위해 고객센터를 운영합니다.

12. 연락처

Yuno 서비스 운영팀
이메일: jys275@kookmin.ac.kr
주소: 서울특별시 성북구 정릉로 77''',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF949CAD),
                                  letterSpacing: -0.266,
                                  height: 16/14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // 개인정보 처리방침 섹션
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '개인정보 처리방침',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: -0.9,
                              height: 22/18,
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 400,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xFF252931),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                '''Yuno(이하 "서비스")는 개인정보보호법 및 관련 법령을 준수하며, 이용자의 개인정보를 안전하게 관리하기 위해 다음과 같이 개인정보처리방침을 공개합니다.

1. 처리하는 개인정보 항목

서비스는 다음의 개인정보만을 수집·이용합니다.

① 회원가입 및 기본 프로필 정보

• 이름 또는 닉네임
• 생년월일(YYYYMMDD)
• 지역
• 학교
• 학력
• 전공

② 서비스 이용 과정에서 자동 수집되는 정보

• 단말기 정보(모델명, OS 버전)
• 앱 이용 기록, 접속 로그
• 오류 로그, 접속 IP(일시적 처리 후 파기)

※ 서비스는 위치 기반 서비스(LBS)를 사용하지 않습니다.
※ 서비스는 주민등록번호를 수집하지 않습니다.

2. 개인정보 수집 이용 목적

서비스는 아래 목적을 위해 개인정보를 처리합니다.

• 개인 조건(나이·지역·학력 등)을 기반으로 한 정책 추천
• 서비스 제공 및 기능 운영
• 회원 식별 및 로그인 유지
• 이용자 고객지원
• 서비스 품질 개선 및 오류 분석
• 법령 준수

3. 개인정보 보유 및 이용기간

• 회원 탈퇴 시 즉시 삭제
• 다만, 아래 정보는 법령 근거에 따라 일정 기간 보관
  - 접속 로그: 3개월(통신비밀보호법)
  - 서비스 부정 이용 기록: 1년

4. 개인정보 제3자 제공

서비스는 법령에 근거하거나 이용자 동의를 받은 경우를 제외하고 개인정보를 제3자에게 제공하지 않습니다.

5. 개인정보 처리위탁

서비스는 현재 개인정보 처리업무를 외부 업체에 위탁하지 않습니다.
향후 위탁 시 사전에 공지합니다.

6. 이용자의 권리 및 행사 방법

이용자는 언제든지 본인의 개인정보에 대해 다음을 요청할 수 있습니다.

• 열람
• 정정
• 삭제
• 처리정지

앱 내 고객센터 또는 이메일을 통해 요청 가능합니다.

7. 개인정보의 파기

• 회원 탈퇴 시 모든 개인정보는 즉시 파기합니다.
• 전자적 파일: 복구 불가능한 기술적 조치 후 삭제
• 문서: 파쇄 혹은 소각

8. 개인정보 보호조치

• 개인정보 암호화 저장
• 접근 권한 최소화
• 보안 로그 및 이상 징후 모니터링
• 데이터 전송 구간 암호화(HTTPS)

9. 개인정보보호 책임자

Yuno 서비스 운영팀
이메일: jys275@kookmin.ac.kr
주소: 서울특별시 성북구 정릉로 77

10. 고지 의무

개인정보처리방침이 변경될 경우, 서비스 공지 후 시행합니다.''',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF949CAD),
                                  letterSpacing: -0.266,
                                  height: 16/14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
