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
                                '''제 1 장 총칙

제 1 조 (목적)
본 약관은 Yuno(이하 "회사"라 합니다)이 운영하는 웹사이트 (이하 "웹사이트"라 합니다)에서 제공하는 온라인 서비스(이하 "서비스"라 한다)를 이용함에 있어 사이버몰과 이용자의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제 2 조 (용어의 정의)
본 약관에서 사용하는 용어는 다음과 같이 정의한다.
1. "웹사이트"란 회사가 재화 또는 용역을 이용자에게 제공하기 위하여 컴퓨터 등 정보통신설비를 이용하여 재화 또는 용역을 거래 할 수 있도록 설정한 가상의 영업장을 말하며, 아울러 사이버몰을 운영하는 사업자의 의미로도 사용합니다.
2. "이용자"란 "웹사이트"에 접속하여 서비스를 이용하는 회원 및 비회원을 말합니다.
3. "회원"이라 함은 "웹사이트"에 개인정보를 제공하여 회원등록을 한 자로서, "웹사이트"의 정보를 지속적으로 제공받으며, "웹사이트"이 제공하는 서비스를 계속적으로 이용할 수 있는 자를 말합니다.
4. "비회원"이라 함은 회원에 가입하지 않고, "웹사이트"이 제공하는 서비스를 이용하는 자를 말합니다.
5. "ID"라 함은 이용자가 회원가입당시 등록한 사용자 "개인이용문자"를 말합니다.
6. "멤버십"이라 함은 회원등록을 한 자로서, 별도의 온/오프라인 상에서 추가 서비스를 제공 받을 수 있는 회원을 말합니다.

제 3 조 (약관의 공시 및 효력과 변경)
1. 본 약관은 회원가입 화면에 게시하여 공시하며 회사는 사정변경 및 영업상 중요한 사유가 있을 경우 약관을 변경할 수 있으며 변경된 약관은 공지사항을 통해 공시한다
2. 본 약관 및 차후 회사사정에 따라 변경된 약관은 이용자에게 공시함으로써 효력을 발생한다.

제 4 조 (약관 외 준칙)
본 약관에 명시되지 않은 사항이 전기통신기본법, 전기통신사업법, 정보통신촉진법, '전자상거래등에서의 소비자 보호에 관한 법률', '약관의 규제에관한법률', '전자거래기본법', '전자서명법', '정보통신망 이용촉진등에 관한 법률', '소비자보호법' 등 기타 관계 법령에 규정되어 있을 경우에는 그 규정을 따르도록 한다.

제 2 장 이용계약

제 5 조 (이용신청)
1. 이용신청자가 회원가입 안내에서 본 약관과 개인정보보호정책에 동의하고 등록절차(회사의 소정 양식의 가입 신청서 작성)를 거쳐 '확인' 버튼을 누르면 이용신청을 할 수 있다.
2. 이용신청자는 반드시 실명과 실제 정보를 사용해야 하며 1개의 생년월일에 대하여 1건의 이용신청을 할 수 있다.
3. 실명이나 실제 정보를 입력하지 않은 이용자는 법적인 보호를 받을 수 없으며, 서비스 이용에 제한을 받을 수 있다.

제 6 조 (이용신청의 승낙)
1. 회사는 제5조에 따른 이용신청자에 대하여 제2항 및 제3항의 경우를 예외로 하여 서비스 이용을 승낙한다.
2. 회사는 아래 사항에 해당하는 경우에 그 제한사유가 해소될 때까지 승낙을 유보할 수 있다.
   가. 서비스 관련 설비에 여유가 없는 경우
   나. 기술상 지장이 있는 경우
   다. 기타 회사 사정상 필요하다고 인정되는 경우
3. 회사는 아래 사항에 해당하는 경우에 승낙을 하지 않을 수 있다.
   가. 다른 사람의 명의를 사용하여 신청한 경우
   나. 이용자 정보를 허위로 기재하여 신청한 경우
   다. 사회의 안녕질서 또는 미풍양속을 저해할 목적으로 신청한 경우
   라. 기타 회사가 정한 이용신청 요건이 미비한 경우

제 3 장 계약 당사자의 의무

제 7 조 (회사의 의무)
1. 회사는 사이트를 안정적이고 지속적으로 운영할 의무가 있다.
2. 회사는 이용자로부터 제기되는 의견이나 불만이 정당하다고 인정될 경우에는 즉시 처리해야 한다. 단, 즉시 처리가 곤란한 경우에는 이용자에게 그 사유와 처리일정을 공지사항 또는 전자우편을 통해 통보해야 한다.
3. 제1항의 경우 수사상의 목적으로 관계기관 및 정보통신윤리위원회의 요청이 있거나 영장 제시가 있는 경우, 기타 관계 법령에 의한 경우는 예외로 한다.

제 8 조 (이용자의 의무)
1. 이용자는 본 약관 및 회사의 공지사항, 사이트 이용안내 등을 숙지하고 준수해야 하며 기타 회사의 업무에 방해되는 행위를 해서는 안된다.
2. 이용자는 회사의 사전 승인 없이 본 사이트를 이용해 어떠한 영리행위도 할 수 없다.
3. 이용자는 본 사이트를 통해 얻는 정보를 회사의 사전 승낙 없이 복사, 복제, 변경, 번역, 출판, 방송 및 기타의 방법으로 사용하거나 이를 타인에게 제공할 수 없다.''',
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
                                '''제 1 장 개인정보 수집 및 이용

제 1 조 (개인정보의 수집 및 이용목적)
회사는 다음의 목적을 위하여 개인정보를 처리합니다. 처리하고 있는 개인정보는 다음의 목적 이외의 용도로는 이용되지 않으며, 이용 목적이 변경되는 경우에는 개인정보보호법 제18조에 따라 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다.

1. 회원가입 및 관리
회원 가입의사 확인, 회원제 서비스 제공에 따른 본인 식별·인증, 회원자격 유지·관리, 서비스 부정이용 방지, 만14세 미만 아동의 개인정보 처리 시 법정대리인의 동의여부 확인, 각종 고지·통지, 고충처리 목적으로 개인정보를 처리합니다.

2. 재화 또는 서비스 제공
물품배송, 서비스 제공, 계약서·청구서 발송, 콘텐츠 제공, 맞춤서비스 제공, 본인인증, 연령인증, 요금결제·정산, 채권추심 목적으로 개인정보를 처리합니다.

3. 고충처리
민원인의 신원 확인, 민원사항 확인, 사실조사를 위한 연락·통지, 처리결과 통보 목적으로 개인정보를 처리합니다.

제 2 조 (개인정보의 처리 및 보유기간)
1. 회사는 법령에 따른 개인정보 보유·이용기간 또는 정보주체로부터 개인정보를 수집 시에 동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.

2. 각각의 개인정보 처리 및 보유 기간은 다음과 같습니다.
   - 회원가입 및 관리: 회원 탈퇴 시까지
   - 재화 또는 서비스 제공: 재화·서비스 공급완료 및 요금결제·정산 완료시까지
   - 고충처리: 고충 처리 완료일로부터 3년

제 3 조 (개인정보의 제3자 제공)
회사는 정보주체의 개인정보를 제1조(개인정보의 처리목적)에서 명시한 범위 내에서만 처리하며, 정보주체의 동의, 법률의 특별한 규정 등 개인정보보호법 제17조에 해당하는 경우에만 개인정보를 제3자에게 제공합니다.

제 4 조 (개인정보처리의 위탁)
회사는 원활한 개인정보 업무처리를 위하여 다음과 같이 개인정보 처리업무를 위탁하고 있습니다.

1. 위탁업체: (주)데이터처리업체
   - 위탁업무 내용: 데이터 보관 및 관리
   - 위탁기간: 회원 탈퇴 시 또는 위탁계약 종료 시까지

제 5 조 (정보주체의 권리·의무 및 행사방법)
1. 정보주체는 회사에 대해 언제든지 다음 각 호의 개인정보 보호 관련 권리를 행사할 수 있습니다.
   - 개인정보 처리현황 통지요구
   - 개인정보 처리정지 요구
   - 개인정보의 수정·삭제 요구
   - 손해배상 청구

2. 제1항에 따른 권리 행사는 회사에 대해 서면, 전화, 전자우편, 모사전송(FAX) 등을 통하여 하실 수 있으며 회사는 이에 대해 지체없이 조치하겠습니다.

제 6 조 (개인정보의 파기)
회사는 개인정보 보유기간의 경과, 처리목적 달성 등 개인정보가 불필요하게 되었을 때에는 지체없이 해당 개인정보를 파기합니다.''',
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
