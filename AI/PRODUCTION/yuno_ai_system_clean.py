"""
Yuno 팀과 완벽 호환되는 AI 추천 시스템 (이모지 제거)
"""

import pandas as pd
import numpy as np
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.decomposition import TruncatedSVD
from datetime import datetime
import json
import random

class YunoAI:
    def __init__(self):
        print("Yuno 호환 AI 시스템 초기화 중...")

        try:
            self.model = SentenceTransformer('paraphrase-multilingual-MiniLM-L12-v2')
            print("BERT 모델 로딩 완료")
        except:
            print("BERT 모델 로딩 실패 - 키워드 매칭으로 대체")
            self.model = None

        self.policies_data = None
        self.policy_embeddings = None
        self.user_item_matrix = None
        self.svd_model = None

    def load_real_data(self, csv_path='real_policies_final.csv'):
        """실제 온통청년 API 데이터 로딩 및 팀 형식으로 변환"""
        try:
            # CSV 로딩
            df = pd.read_csv(csv_path, encoding='utf-8-sig')
            print(f"전체 데이터 로딩: {len(df)}개 정책")

            # 2025년도 정책만 필터링 (ID가 2025로 시작하는 것만)
            df['id'] = df['id'].astype(str)
            df = df[df['id'].str.startswith('2025')]
            print(f"2025년 정책 필터링: {len(df)}개 정책")

            # 팀 백엔드 API 형식으로 변환
            policies = []
            for _, row in df.iterrows():
                # Requirements 생성
                requirements = []
                age_min = row.get('age_min', '')
                age_max = row.get('age_max', '')
                if pd.notna(age_min) and pd.notna(age_max):
                    requirements.append(f"만 {int(age_min)}세~{int(age_max)}세")

                qualification = row.get('qualification', '')
                if pd.notna(qualification) and str(qualification).strip():
                    qual_text = str(qualification)[:50]  # 첫 50자만
                    requirements.append(qual_text)

                # 신청기간 파싱
                app_period = str(row.get('application_period', ''))
                aply_prd_se_cd = "상시" if "상시" in app_period else "기간"
                aply_prd_end_ymd = None
                if '~' in app_period:
                    parts = app_period.split('~')
                    if len(parts) == 2:
                        end_date = parts[1].strip().replace('.', '').replace('-', '')[:8]
                        if end_date.isdigit():
                            aply_prd_end_ymd = end_date

                policy_dict = {
                    "id": str(row.get('id', '')),
                    "plcyNm": str(row.get('title', '')),
                    "bscPlanPlcyWayNoNm": str(row.get('category_major', '')),
                    "plcyExplnCn": str(row.get('description', '')),
                    "rgtrupInstCdNm": str(row.get('supervisor', '전국')),
                    "aplyPrdSeCd": aply_prd_se_cd,
                    "aplyPrdEndYmd": aply_prd_end_ymd,
                    "applicationUrl": str(row.get('reference_url', '')),
                    "requirements": requirements if requirements else ["청년 대상"],
                    "saves": int(row.get('view_count', 0)) if pd.notna(row.get('view_count')) else 0,
                    "isBookmarked": False,
                    # 추가 정보 (검색에 활용)
                    "support_content": str(row.get('support_content', '')),
                    "keywords": str(row.get('keywords', '')),
                    "category_minor": str(row.get('category_minor', ''))
                }
                policies.append(policy_dict)

            self.policies_data = pd.DataFrame(policies)
            print(f"{len(policies)}개 실제 정책 데이터 변환 완료")

        except FileNotFoundError:
            print(f"[ERROR] {csv_path} 파일을 찾을 수 없습니다!")
            self.policies_data = pd.DataFrame()
        except Exception as e:
            print(f"[ERROR] 데이터 로딩 실패: {e}")
            self.policies_data = pd.DataFrame()

        # BERT 임베딩 생성
        if self.model and len(self.policies_data) > 0:
            policy_texts = []
            for _, policy in self.policies_data.iterrows():
                # 정책명 + 설명 + 카테고리 + 지원내용 + 키워드
                text_parts = [
                    str(policy.get('plcyNm', '')),
                    str(policy.get('plcyExplnCn', '')),
                    str(policy.get('bscPlanPlcyWayNoNm', '')),
                    str(policy.get('category_minor', '')),
                    str(policy.get('support_content', ''))[:200],  # 지원내용 앞부분
                    str(policy.get('keywords', ''))
                ]
                text = ' '.join([t for t in text_parts if t and t != 'nan'])
                policy_texts.append(text)

            print(f"BERT 임베딩 생성 중... ({len(policy_texts)}개 정책)")
            self.policy_embeddings = self.model.encode(policy_texts, show_progress_bar=True)
            print(f"BERT 임베딩 생성 완료: {self.policy_embeddings.shape}")

    def get_recommendations(self, user_profile, top_k=3):
        """
        팀 백엔드 API 응답 형식과 100% 일치하는 추천
        """
        print(f"사용자 추천 생성 중: {user_profile}")

        # 사용자 쿼리 생성 - BERT 모델을 위한 자연어 문장 형식
        age = user_profile.get('age', 25)
        gender = user_profile.get('gender', '')
        education = user_profile.get('education', '')
        major = user_profile.get('major', '')
        interests = user_profile.get('interests', [])
        location = user_profile.get('location', '')

        # 자연스러운 문장 형태로 사용자 프로필 구성
        query_parts = []
        if age:
            query_parts.append(f"{age}세")
        if gender:
            query_parts.append(gender)
        if education:
            query_parts.append(f"{education} 학력")
        if major:
            query_parts.append(f"{major} 전공")

        user_query = f"{' '.join(query_parts)} 청년이"

        if interests:
            interests_text = ', '.join(interests)
            user_query += f" {interests_text}에 관심이 있습니다."
        else:
            user_query += " 청년 정책을 찾고 있습니다."

        if location:
            user_query += f" {location} 지역에서 지원 가능한 정책을 원합니다."

        print(f"사용자 쿼리: {user_query}")

        scores = []
        user_location = user_profile.get('location', '')

        if self.model and self.policy_embeddings is not None:
            # BERT 기반 추천
            user_embedding = self.model.encode([user_query])
            similarities = cosine_similarity(user_embedding, self.policy_embeddings)[0]

            for i, similarity in enumerate(similarities):
                policy = self.policies_data.iloc[i].copy()

                # 지역 필터링 (가장 중요!)
                policy_region = str(policy.get('rgtrupInstCdNm', '전국'))
                if user_location:
                    # 사용자 지역이 있을 때: 해당 지역 OR 전국 정책만
                    if user_location not in policy_region and '전국' not in policy_region:
                        continue  # 다른 지역 정책은 제외

                # 나이 필터링
                user_age = user_profile.get('age')
                if user_age and pd.notna(policy.get('age_min')) and pd.notna(policy.get('age_max')):
                    age_min = int(policy['age_min'])
                    age_max = int(policy['age_max'])
                    if not (age_min <= user_age <= age_max):
                        continue  # 나이 조건 불일치 정책 제외

                # 카테고리 매칭 보너스 (모든 대분류 동일한 중요도)
                interests = user_profile.get('interests', [])
                policy_category = policy['bscPlanPlcyWayNoNm']

                # 관심사에 해당하는 카테고리면 1.3배 보너스
                if any(interest in interests for interest in ['취업', '창업', '일자리']) and policy_category == '일자리':
                    similarity *= 1.3
                elif any(interest in interests for interest in ['장학금', '교육', '학비']) and policy_category == '교육':
                    similarity *= 1.3
                elif any(interest in interests for interest in ['문화', '여가', '복지']) and policy_category == '복지문화':
                    similarity *= 1.3
                elif any(interest in interests for interest in ['주거', '집', '청약', '임대']) and policy_category == '주거':
                    similarity *= 1.3
                elif any(interest in interests for interest in ['대출', '금융', '자금', '융자']) and policy_category == '생활금융':
                    similarity *= 1.3

                scores.append((i, similarity))
        else:
            # 키워드 기반 매칭 (BERT 없을 때)
            for i, (_, policy) in enumerate(self.policies_data.iterrows()):
                # 지역 필터링
                policy_region = str(policy.get('rgtrupInstCdNm', '전국'))
                if user_location:
                    if user_location not in policy_region and '전국' not in policy_region:
                        continue

                # 나이 필터링
                user_age = user_profile.get('age')
                if user_age and pd.notna(policy.get('age_min')) and pd.notna(policy.get('age_max')):
                    age_min = int(policy['age_min'])
                    age_max = int(policy['age_max'])
                    if not (age_min <= user_age <= age_max):
                        continue  # 나이 조건 불일치 정책 제외

                score = 0.1  # 기본 점수

                # 카테고리 매칭 보너스 (모든 대분류 동일한 중요도)
                interests = user_profile.get('interests', [])
                policy_category = policy['bscPlanPlcyWayNoNm']

                # 관심사에 해당하는 카테고리면 점수 상승
                if any(interest in interests for interest in ['취업', '창업', '일자리']) and policy_category == '일자리':
                    score = 0.8
                elif any(interest in interests for interest in ['장학금', '교육', '학비']) and policy_category == '교육':
                    score = 0.8
                elif any(interest in interests for interest in ['문화', '여가', '복지']) and policy_category == '복지문화':
                    score = 0.8
                elif any(interest in interests for interest in ['주거', '집', '청약', '임대']) and policy_category == '주거':
                    score = 0.8
                elif any(interest in interests for interest in ['대출', '금융', '자금', '융자']) and policy_category == '생활금융':
                    score = 0.8

                scores.append((i, score))

        # 상위 10개 중 랜덤으로 K개 선택 (새로고침할 때마다 다른 추천)
        scores.sort(key=lambda x: x[1], reverse=True)

        # 상위 10개 후보 선택
        candidate_count = min(10, len(scores))
        top_candidates = scores[:candidate_count]

        # 랜덤으로 top_k개 선택
        num_to_select = min(top_k, len(top_candidates))
        selected_indices = random.sample(range(len(top_candidates)), num_to_select)

        top_policies = []
        for i in selected_indices:
            idx, score = top_candidates[i]
            policy = self.policies_data.iloc[idx].copy()
            policy_dict = policy.to_dict()
            policy_dict['recommendationScore'] = float(score)
            top_policies.append(policy_dict)

        # 추천 점수 순으로 정렬
        top_policies.sort(key=lambda x: x['recommendationScore'], reverse=True)

        # 팀 백엔드 API 응답 형식 (완전 일치)
        response = {
            "success": True,
            "message": "AI recommendations generated successfully",
            "data": top_policies,
            "total": len(top_policies),
            "page": 1,
            "limit": top_k
        }

        return response

def test_system():
    print("=" * 50)
    print("Yuno AI 시스템 테스트 (실제 데이터)")
    print("=" * 50)

    # 시스템 초기화
    ai = YunoAI()
    ai.load_real_data('real_policies_final.csv')

    # 테스트 사용자 (팀 앱에서 보낼 형식)
    test_user = {
        "user_id": "user_001",
        "age": 23,
        "major": "컴퓨터공학",
        "interests": ["취업", "창업"],
        "location": "서울"
    }

    print(f"테스트 사용자: {test_user}")

    # 추천 생성
    result = ai.get_recommendations(test_user, top_k=3)

    print(f"\n추천 결과:")
    print(f"성공: {result['success']}")
    print(f"총 개수: {result['total']}")

    print(f"\n추천 정책 목록:")
    for i, policy in enumerate(result['data']):
        print(f"{i+1}. {policy['plcyNm']}")
        print(f"   카테고리: {policy['bscPlanPlcyWayNoNm']}")
        print(f"   추천점수: {policy['recommendationScore']:.3f}")
        print(f"   URL: {policy['applicationUrl']}")
        print()

    # JSON 파일로 저장 (팀 백엔드 테스트용)
    with open('yuno_ai_response.json', 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2, default=str)

    print("=" * 50)
    print("테스트 완료! yuno_ai_response.json 파일 생성됨")
    print("이 JSON을 팀 백엔드 API 응답으로 바로 사용 가능!")

if __name__ == "__main__":
    test_system()