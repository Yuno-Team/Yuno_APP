# Yuno AI 추천 시스템

청년 정책 맞춤형 추천을 위한 AI 시스템

## 📖 프로젝트 개요

Yuno 앱 사용자에게 **개인 맞춤형 청년 정책**을 추천하는 AI 시스템입니다.
- 사용자 프로필(나이, 전공, 관심사)을 기반으로 관련 정책 추천
- 3가지 추천 알고리즘 제공 (BERT, 하이브리드, 협업 필터링)
- 온통청년 공공 API에서 수집한 **2,700개 실제 정책 데이터** 활용

## 🎯 주요 기능

### 1. BERT 기반 컨텐츠 추천
- 사용자 프로필과 정책 텍스트의 의미적 유사도 계산
- 전공, 키워드 매칭에 강함
- 정확도: **100%** (테스트 데이터 기준)

### 2. 하이브리드 추천
- 컨텐츠 기반(70%) + 협업 필터링(30%) 결합
- 정확도와 인기도 균형
- 실용적인 정책 우선 추천 (창업자금, 장학금 등)

### 3. 협업 필터링
- 사용자 행동 패턴 학습
- 유사 사용자 기반 추천
- 인기 정책 우선 노출

## 📊 데이터

### 수집 소스
- **온통청년 공공 API** (https://www.youthcenter.go.kr)
- 2,700개 청년 정책 (2025년 1월 기준)

### 카테고리 분포
| 카테고리 | 정책 수 |
|---------|--------|
| 일자리 | 757개 |
| 복지문화 | 589개 |
| 생활복지 | 310개 |
| 주거 | 232개 |
| 교육 | 159개 |
| 기타 | 653개 |

### 주요 컬럼
- 제목, 카테고리, 설명, 지원내용
- 신청기간, 신청방법, 선발방법
- 대상 연령, 지역, 담당기관
- 조회수, 키워드

## 🚀 빠른 시작

### 1. 환경 설정
```bash
cd AI/PRODUCTION
pip install -r requirements.txt
```

### 2. 모델 테스트
```bash
python test_single_user.py
```

### 3. 사용 예시
```python
from yuno_ai_system_clean import YunoAI

# AI 시스템 초기화
ai = YunoAI()
ai.load_real_data('real_policies_final.csv')

# 사용자 프로필
user = {
    "user_id": "user_001",
    "age": 24,
    "major": "컴퓨터공학",
    "interests": ["취업", "창업"],
    "location": "서울"
}

# 추천 받기
recommendations = ai.get_recommendations(user, top_k=5)

# 결과 출력
for policy in recommendations['data']:
    print(f"- {policy['plcyNm']}")
    print(f"  카테고리: {policy['bscPlanPlcyWayNoNm']}")
    print(f"  점수: {policy['recommendationScore']:.3f}")
```

## 📂 프로젝트 구조

```
AI/
├── PRODUCTION/          # 메인 코드
│   ├── yuno_ai_system_clean.py              # BERT 추천
│   ├── hybrid_system_lite.py                # 하이브리드 추천
│   ├── complete_collaborative_filtering_system.py  # 협업 필터링
│   ├── real_policies_final.csv              # 실제 데이터
│   ├── collect_final.py                     # 데이터 수집
│   ├── test_single_user.py                  # 모델 테스트
│   ├── quick_experiment.py                  # 성능 실험
│   └── README.md                            # 상세 가이드
│
└── DOCS/                # 문서
    └── README.md        # 이 파일
```

## 🧪 성능 평가

### 테스트 결과
- **Precision@3**: 100%
- **Diversity**: 33.3%
- **응답 시간**: 1-2초

### 최적 설정
- 하이브리드 가중치: **0.5 / 0.5** (컨텐츠 / 협업)
- 추천 개수: **K=3**

## 🔧 기술 스택

### AI/ML
- **sentence-transformers** - BERT 임베딩
- **scikit-learn** - 협업 필터링 (SVD)
- **pandas** / **numpy** - 데이터 처리

### API
- 온통청년 공공 API

### 언어
- Python 3.12

## 📈 성능 개선

### 실험 가능한 항목
1. **하이브리드 가중치 조정** - 컨텐츠 vs 협업 비율
2. **Top-K 최적화** - 추천 개수 조정
3. **BERT 모델 변경** - 더 큰 모델 시도
4. **카테고리 가중치** - 특정 카테고리 우선순위

### 실험 실행
```bash
python quick_experiment.py
# 약 5분 소요
# 결과: quick_experiment_results.json
```

자세한 내용은 `AI/PRODUCTION/EXPERIMENT_GUIDE.md` 참조

## 🔄 데이터 업데이트

### 월 1회 권장
```bash
python collect_final.py
# 최신 정책 데이터 수집
# real_policies_final.csv 갱신
```

## 📊 모델 비교

| 모델 | 강점 | 약점 | 추천 시나리오 |
|------|------|------|--------------|
| BERT | 텍스트 매칭 정확 | 인기도 무시 | 전공/키워드 중요 시 |
| 하이브리드 | 균형잡힌 추천 | 복잡함 | 일반적 상황 |
| 협업 필터링 | 사용자 패턴 학습 | Cold start 문제 | 행동 데이터 풍부 시 |

## 🎯 다음 단계

### Phase 1: 백엔드 통합 ✅
- [x] BERT 추천 API
- [x] 하이브리드 추천 API
- [x] 협업 필터링 API

### Phase 2: 실 서비스 배포
- [ ] FastAPI 서비스화
- [ ] 응답 캐싱
- [ ] 모니터링 시스템

### Phase 3: 지속적 개선
- [ ] 실제 사용자 데이터 수집
- [ ] A/B 테스트
- [ ] 온라인 학습
- [ ] 계절별 트렌드 반영

## 📝 개발 이력

### 2025.11.04
- ✅ 온통청년 API 연동 (2,700개 정책)
- ✅ 3가지 AI 모델 실제 데이터 전환
- ✅ 통합 테스트 시스템 구축
- ✅ 성능 실험 (Precision 100% 달성)

### 2025.09.24
- 초기 BERT 모델 개발
- 더미 데이터로 프로토타입 구축

## 🤝 기여

문의사항이나 버그 리포트는 이슈로 남겨주세요.

## 📄 라이센스

이 프로젝트는 Yuno 팀의 소유입니다.

---

**더 자세한 사용법은 `AI/PRODUCTION/README.md`를 참조하세요.**
