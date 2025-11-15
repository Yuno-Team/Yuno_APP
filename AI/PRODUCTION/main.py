"""
Yuno AI FastAPI Server
BERT 기반 청년 정책 추천 API 서버
"""

from fastapi import FastAPI, HTTPException, Query, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, ConfigDict
from typing import List, Optional, Dict, Any
import uvicorn
from datetime import datetime
import hashlib
import json
from contextlib import asynccontextmanager
import os
from dotenv import load_dotenv
from google import genai

from yuno_ai_system_clean import YunoAI

# 환경 변수 로드
load_dotenv()

# 전역 AI 모델 (서버 시작시 한번만 로딩)
ai_model: Optional[YunoAI] = None

# Gemini 설정
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if GEMINI_API_KEY:
    gemini_client = genai.Client(api_key=GEMINI_API_KEY)
    print("Gemini API configured successfully")
else:
    gemini_client = None
    print("WARNING: Gemini API key not found")

# 라이프사이클 관리
@asynccontextmanager
async def lifespan(app: FastAPI):
    """서버 시작/종료 처리"""
    global ai_model
    # Startup
    print("=" * 70)
    print("Yuno AI Server Starting...")
    print("=" * 70)

    try:
        ai_model = YunoAI()
        ai_model.load_real_data('real_policies_final.csv')
        print(f"BERT Model Loaded: {len(ai_model.policies_data)} policies")
        print("Server Ready!")
        print("=" * 70)
    except Exception as e:
        print(f"ERROR: Failed to load AI model - {e}")
        raise

    yield

    # Shutdown
    print("=" * 70)
    print("Yuno AI Server Shutting Down...")
    print("=" * 70)

# FastAPI 앱 초기화
app = FastAPI(
    title="Yuno AI Recommendation API",
    description="청년 정책 맞춤형 추천 시스템",
    version="1.0.0",
    lifespan=lifespan
)

# CORS 설정 (프론트엔드 연동)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 프로덕션에서는 구체적인 도메인 지정
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 커스텀 예외 핸들러 (422 에러 디버깅용)
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    body = await request.body()
    print(f"Validation Error - Request body: {body.decode()}")
    print(f"Validation errors: {exc.errors()}")
    return JSONResponse(
        status_code=422,
        content={"detail": exc.errors(), "body": body.decode()}
    )

# 간단한 캐시 (메모리 기반)
recommendation_cache: Dict[str, Any] = {}
summary_cache: Dict[str, str] = {}
MAX_CACHE_SIZE = 1000

# Request/Response 모델
class UserProfile(BaseModel):
    """사용자 프로필"""
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "user_id": "user_001",
                "age": 24,
                "major": "컴퓨터공학",
                "interests": ["취업", "창업"],
                "location": "서울"
            }
        }
    )

    user_id: str = Field(..., description="사용자 ID")
    age: int = Field(..., ge=15, le=39, description="나이 (15-39세)")
    major: Optional[str] = Field(None, description="전공")
    interests: List[str] = Field(default_factory=list, description="관심사 리스트")
    location: Optional[str] = Field(None, description="지역")

class PolicyRecommendation(BaseModel):
    """정책 추천 응답"""
    model_config = ConfigDict(extra='allow')  # 추가 필드 허용

    id: str
    plcyNm: str
    bscPlanPlcyWayNoNm: str
    plcyExplnCn: Optional[str] = None
    rgtrupInstCdNm: Optional[str] = None
    aplyPrdSeCd: Optional[str] = None
    aplyPrdEndYmd: Optional[str] = None
    applicationUrl: Optional[str] = None
    requirements: Optional[List[str]] = None
    saves: Optional[int] = 0
    isBookmarked: Optional[bool] = False
    recommendationScore: float

class RecommendationResponse(BaseModel):
    """추천 결과"""
    model_config = ConfigDict(extra='allow')  # 추가 필드 허용

    success: bool
    user_id: str
    timestamp: str
    total_recommendations: int
    data: List[Dict[str, Any]]  # 유연한 dict 타입 사용
    cached: bool = False

class HealthResponse(BaseModel):
    """헬스 체크"""
    status: str
    model_loaded: bool
    total_policies: int
    timestamp: str

class SummaryRequest(BaseModel):
    """정책 요약 요청"""
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "policy_id": "20240703005400200002",
                "user_age": 24,
                "user_major": "컴퓨터공학",
                "user_interests": ["취업", "창업"]
            }
        }
    )

    policy_id: str = Field(..., description="정책 ID")
    user_age: Optional[int] = Field(None, ge=15, le=39, description="사용자 나이")
    user_major: Optional[str] = Field(None, description="사용자 전공")
    user_interests: Optional[List[str]] = Field(default_factory=list, description="사용자 관심사")

class SummaryResponse(BaseModel):
    """정책 요약 응답"""
    success: bool
    policy_id: str
    policy_title: str
    summary: str
    timestamp: str
    cached: bool = False


# 유틸리티 함수
def get_cache_key(user_profile: UserProfile, top_k: int) -> str:
    """캐시 키 생성"""
    profile_str = json.dumps({
        "age": user_profile.age,
        "major": user_profile.major,
        "interests": sorted(user_profile.interests),
        "location": user_profile.location,
        "top_k": top_k
    }, sort_keys=True)
    return hashlib.md5(profile_str.encode()).hexdigest()


def clean_cache():
    """캐시 크기 제한"""
    global recommendation_cache
    if len(recommendation_cache) > MAX_CACHE_SIZE:
        # 가장 오래된 항목 삭제 (FIFO)
        keys_to_remove = list(recommendation_cache.keys())[:MAX_CACHE_SIZE // 2]
        for key in keys_to_remove:
            del recommendation_cache[key]


# API 엔드포인트
@app.get("/", tags=["Root"])
async def root():
    """루트 엔드포인트"""
    return {
        "message": "Yuno AI Recommendation API",
        "version": "1.0.0",
        "docs": "/docs"
    }


@app.get("/health", response_model=HealthResponse, tags=["Health"])
async def health_check():
    """헬스 체크"""
    return {
        "status": "healthy" if ai_model else "unhealthy",
        "model_loaded": ai_model is not None,
        "total_policies": len(ai_model.policies_data) if ai_model else 0,
        "timestamp": datetime.now().isoformat()
    }


@app.post("/api/recommendations", response_model=RecommendationResponse, tags=["Recommendations"])
async def get_recommendations(
    user_profile: UserProfile,
    top_k: int = Query(5, ge=1, le=20, description="추천 개수 (1-20)")
):
    """
    사용자 프로필 기반 정책 추천

    - **user_id**: 사용자 ID
    - **age**: 나이 (15-39세)
    - **major**: 전공 (선택)
    - **interests**: 관심사 리스트 (선택)
    - **location**: 지역 (선택)
    - **top_k**: 추천 개수 (기본 5개)
    """
    if not ai_model:
        raise HTTPException(status_code=503, detail="AI model not loaded")

    try:
        # 캐시 확인
        cache_key = get_cache_key(user_profile, top_k)
        if cache_key in recommendation_cache:
            cached_result = recommendation_cache[cache_key]
            return RecommendationResponse(
                success=True,
                user_id=user_profile.user_id,
                timestamp=datetime.now().isoformat(),
                total_recommendations=len(cached_result),
                data=cached_result,
                cached=True
            )

        # AI 추천 실행
        user_dict = {
            "user_id": user_profile.user_id,
            "age": user_profile.age,
            "major": user_profile.major or "",
            "interests": user_profile.interests,
            "location": user_profile.location or ""
        }

        result = ai_model.get_recommendations(user_dict, top_k=top_k)

        if not result.get('success'):
            raise HTTPException(
                status_code=500,
                detail=result.get('message', 'Recommendation failed')
            )

        recommendations = result['data']

        # 캐시 저장
        recommendation_cache[cache_key] = recommendations
        clean_cache()

        return RecommendationResponse(
            success=True,
            user_id=user_profile.user_id,
            timestamp=datetime.now().isoformat(),
            total_recommendations=len(recommendations),
            data=recommendations,
            cached=False
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal error: {str(e)}")


@app.post("/api/summary", response_model=SummaryResponse, tags=["AI Summary"])
async def get_policy_summary(request: SummaryRequest):
    """
    정책 상세 AI 요약 (Gemini API 사용)

    사용자 프로필에 맞춘 맞춤형 정책 요약 생성
    """
    if not gemini_client:
        raise HTTPException(status_code=503, detail="Gemini API not configured")

    if not ai_model:
        raise HTTPException(status_code=503, detail="AI model not loaded")

    try:
        # 캐시 키 생성
        cache_key = f"{request.policy_id}_{request.user_age}_{request.user_major}_{'_'.join(request.user_interests or [])}"

        # 캐시 확인
        if cache_key in summary_cache:
            policy = ai_model.policies_data[ai_model.policies_data['id'] == request.policy_id].iloc[0]
            return SummaryResponse(
                success=True,
                policy_id=request.policy_id,
                policy_title=policy['plcyNm'],
                summary=summary_cache[cache_key],
                timestamp=datetime.now().isoformat(),
                cached=True
            )

        # 정책 정보 조회
        policy_df = ai_model.policies_data[ai_model.policies_data['id'] == request.policy_id]

        if policy_df.empty:
            raise HTTPException(status_code=404, detail="Policy not found")

        policy = policy_df.iloc[0]

        # Gemini 프롬프트 생성
        user_info = ""
        if request.user_age:
            user_info += f"나이: {request.user_age}세\n"
        if request.user_major:
            user_info += f"전공: {request.user_major}\n"
        if request.user_interests:
            user_info += f"관심사: {', '.join(request.user_interests)}\n"

        user_info_section = f"사용자 정보:\n{user_info}" if user_info else ""

        prompt = f"""다음 정책 정보를 보고, 사용자에게 맞춤형 요약을 2-3문장으로 작성해주세요.

정책 정보:
- 제목: {policy['plcyNm']}
- 설명: {policy['plcyExplnCn']}
- 카테고리: {policy['bscPlanPlcyWayNoNm']}
- 지원 내용: {policy.get('support_content', '정보 없음')}

{user_info_section}

요구사항:
1. 친근하고 격려하는 말투 사용
2. 사용자 정보가 있다면 그에 맞춰 설명
3. 정책의 핵심 혜택과 왜 이 사용자에게 적합한지 설명
4. 2-3문장으로 간결하게
5. 이모지는 사용하지 말 것"""

        # Gemini API 호출 (새 SDK)
        response = gemini_client.models.generate_content(
            model='gemini-2.0-flash-exp',
            contents=prompt
        )
        summary_text = response.text.strip()

        # 캐시 저장
        summary_cache[cache_key] = summary_text

        return SummaryResponse(
            success=True,
            policy_id=request.policy_id,
            policy_title=policy['plcyNm'],
            summary=summary_text,
            timestamp=datetime.now().isoformat(),
            cached=False
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Summary generation failed: {str(e)}")


@app.delete("/api/cache", tags=["Admin"])
async def clear_cache():
    """캐시 초기화 (관리자용)"""
    global recommendation_cache, summary_cache
    rec_cache_size = len(recommendation_cache)
    sum_cache_size = len(summary_cache)
    recommendation_cache = {}
    summary_cache = {}
    return {
        "success": True,
        "message": f"Cache cleared (recommendations: {rec_cache_size}, summaries: {sum_cache_size})",
        "timestamp": datetime.now().isoformat()
    }


@app.get("/api/stats", tags=["Admin"])
async def get_stats():
    """서버 통계"""
    return {
        "model_loaded": ai_model is not None,
        "gemini_configured": gemini_client is not None,
        "total_policies": len(ai_model.policies_data) if ai_model else 0,
        "recommendation_cache_size": len(recommendation_cache),
        "summary_cache_size": len(summary_cache),
        "max_cache_size": MAX_CACHE_SIZE,
        "timestamp": datetime.now().isoformat()
    }


# 서버 실행
if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,  # 개발 모드
        log_level="info"
    )

