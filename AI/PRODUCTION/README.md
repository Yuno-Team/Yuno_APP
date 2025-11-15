# AI/PRODUCTION 폴더 가이드

## 📁 파일 구조 및 역할

### 🤖 AI 추천 모델 (3개) - 핵심

#### 1. `yuno_ai_system_clean.py` (9.1K)
**역할:** BERT 기반 컨텐츠 추천 시스템
- 2,700개 정책을 384차원 벡터로 임베딩
- 사용자 프로필(전공, 관심사)과 정책 텍스트 유사도 계산
- 카테고리 매칭 보너스 적용

**사용법:**
```python
from yuno_ai_system_clean import YunoAI

ai = YunoAI()
ai.load_real_data('real_policies_final.csv')

user = {
    "user_id": "user_001",
    "age": 24,
    "major": "컴퓨터공학",
    "interests": ["취업", "창업"]
}

result = ai.get_recommendations(user, top_k=5)
# result['data']에 추천 정책 5개
```

**특징:**
- 가장 정확한 텍스트 매칭
- 전공/키워드 기반 추천
- 응답 속도: 1-2초

---

#### 2. `hybrid_system_lite.py` (11K)
**역할:** 하이브리드 추천 시스템 (컨텐츠 + 협업 필터링)
- 컨텐츠 기반 70% + 협업 필터링 30% 결합
- 사용자 관심사 + 인기도 함께 고려
- 실용적인 추천 (창업자금, 장학금 등)

**사용법:**
```python
from hybrid_system_lite import HybridSystemLite

hybrid = HybridSystemLite()
hybrid.load_data('real_policies_final.csv')

user = {
    "user_id": "user_002",
    "age": 22,
    "major": "경영학",
    "interests": ["장학금", "주거"]
}

result = hybrid.get_hybrid_recommendations(user, top_k=5)
# contentScore와 cfScore 모두 포함
```

**특징:**
- 정확도와 인기도 균형
- 컨텐츠/협업 점수 세부 제공
- 가중치 조정 가능 (라인 190)

---

#### 3. `complete_collaborative_filtering_system.py` (25K)
**역할:** 협업 필터링 추천 시스템
- 사용자-정책 상호작용 매트릭스 기반
- SVD(Matrix Factorization) 사용
- User-based(40%) + Item-based(60%) 하이브리드

**사용법:**
```python
from complete_collaborative_filtering_system import CompleteCFSystem

cf = CompleteCFSystem()
cf.create_team_compatible_data(sample_size=100)
cf.generate_realistic_users(60)
cf.generate_smart_interactions()
cf.train_collaborative_models()

user = {"user_id": "user_003", "age": 27, ...}
result = cf.get_collaborative_recommendations(user, top_k=5)
```

**특징:**
- 사용자 행동 패턴 학습
- 유사 사용자 기반 추천
- 새 사용자는 인기도 기반

---

### 📊 데이터 (1개) - 필수

#### 4. `real_policies_final.csv` (3.8MB)
**역할:** 온통청년 API에서 수집한 실제 정책 데이터

**내용:**
- 2,700개 청년 정책
- 23개 컬럼 (제목, 카테고리, 설명, 지원내용, 신청기간 등)

**컬럼 구조:**
```
id, title, category_major, category_minor, description,
support_content, keywords, age_min, age_max,
application_period, application_method, selection_method,
reference_url, supervisor, operator, support_scale,
documents, qualification, view_count, zip_code,
first_reg_date, last_modified_date, collected_at
```

**카테고리 분포:**
- 일자리: 757개
- 복지문화: 589개
- 생활복지: 310개
- 주거: 232개
- 교육: 159개
- 기타: 653개

---

### 🔧 유틸리티 스크립트 (3개)

#### 5. `collect_final.py` (5.5K)
**역할:** 온통청년 API에서 데이터 재수집

**사용 시기:**
- 정책 데이터 업데이트 필요 시
- 새로운 정책 추가 시
- real_policies_final.csv 손상 시

**실행:**
```bash
python collect_final.py
# 약 2-3분 소요
# real_policies_final.csv 새로 생성
```

**API 정보:**
- 엔드포인트: https://www.youthcenter.go.kr/go/ythip/getPlcy
- API 키: ad635a05-453c-41a0-9d93-78bcd8de81bf
- 페이지당 100개, 최대 50페이지

---

#### 6. `data_preprocessing.py` (7.3K)
**역할:** 데이터 전처리 및 정제

**기능:**
- 결측치 처리
- 텍스트 정제 (특수문자 제거)
- 카테고리 표준화
- 나이 범위 검증

**사용법:**
```python
from data_preprocessing import preprocess_policies

df = pd.read_csv('real_policies_final.csv')
clean_df = preprocess_policies(df)
```

---

#### 7. `test_single_user.py` (4.5K)
**역할:** 3가지 AI 모델 통합 테스트 (빠른 버전)

**실행:**
```bash
python test_single_user.py
# 약 2-3분 소요
```

**결과:**
- 3가지 모델 추천 비교
- 카테고리 분포 분석
- single_user_test_result.json 생성

**사용 시기:**
- 모델 정상 작동 확인
- 추천 결과 빠른 확인
- 데모/프레젠테이션

---

### 🧪 실험 및 최적화 (1개)

#### 8. `quick_experiment.py` (6.0K)
**역할:** 빠른 성능 실험 (하이퍼파라미터 튜닝)

**실험 내용:**
1. 하이브리드 가중치 조합 테스트 (0.5/0.5, 0.6/0.4, 0.7/0.3, 0.8/0.2)
2. Top-K 추천 개수 최적화 (K=3, 5, 7, 10)

**실행:**
```bash
python quick_experiment.py
# 약 5분 소요
```

**결과:**
- Precision@K 계산
- Diversity 계산
- 최적 설정값 제안
- quick_experiment_results.json 생성

**사용 시기:**
- 모델 성능 개선 필요 시
- 새로운 가중치 조합 테스트
- A/B 테스트 전

---

### 📄 문서 (3개)

#### 9. `EXPERIMENT_GUIDE.md` (6.3K)
**역할:** 성능 개선 실험 상세 가이드

**내용:**
- 실험 가능한 항목들
- 평가 지표 설명
- 실험 실행 방법
- 결과 적용 방법
- 문제 해결

#### 10. `file_cleanup_analysis.md` (4.5K)
**역할:** 파일 정리 분석 (방금 생성)

**내용:**
- 파일별 역할 분석
- 삭제 가능 파일 목록
- 용량 절약 계산

#### 11. `requirements.txt` (143B)
**역할:** Python 패키지 의존성 목록

**내용:**
```
pandas
numpy
scikit-learn
sentence-transformers
requests
```

**설치:**
```bash
pip install -r requirements.txt
```

---

## 🚀 빠른 시작 가이드

### 1. 의존성 설치
```bash
pip install -r requirements.txt
```

### 2. 모델 테스트
```bash
python test_single_user.py
```

### 3. 사용자 추천 받기
```python
from yuno_ai_system_clean import YunoAI

ai = YunoAI()
ai.load_real_data('real_policies_final.csv')

user = {
    "user_id": "my_user",
    "age": 25,
    "major": "컴퓨터공학",
    "interests": ["취업", "창업"]
}

recommendations = ai.get_recommendations(user, top_k=5)
print(recommendations)
```

---

## 📊 모델 비교

| 모델 | 강점 | 약점 | 속도 | 추천 시나리오 |
|------|------|------|------|--------------|
| **BERT** | 텍스트 매칭 정확 | 인기도 무시 | 보통 | 전공/키워드 중요 시 |
| **하이브리드** | 균형잡힌 추천 | 복잡함 | 보통 | 일반적 추천 |
| **협업 필터링** | 사용자 패턴 학습 | Cold start | 빠름 | 행동 데이터 있을 시 |

---

## 🔄 정기 업데이트

### 월 1회 권장
```bash
# 1. 최신 정책 데이터 수집
python collect_final.py

# 2. 모델 테스트
python test_single_user.py

# 3. 성능 실험 (선택적)
python quick_experiment.py
```

---

## 💡 다음 단계

1. **백엔드 API 통합**
   - FastAPI로 서비스화
   - REST API 엔드포인트 구축

2. **실제 사용자 데이터 수집**
   - 클릭/북마크 로그
   - 신청 완료 데이터

3. **A/B 테스트**
   - 3가지 모델 성능 비교
   - 사용자 만족도 측정

4. **지속적 개선**
   - 주기적 재학습
   - 계절별 트렌드 반영
   - 사용자 피드백 반영
