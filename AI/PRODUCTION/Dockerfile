FROM python:3.11-slim

WORKDIR /app

# 시스템 패키지 업데이트 및 필수 도구 설치
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Python 의존성 파일 복사 및 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 코드 복사
COPY main.py .
COPY yuno_ai_system_clean.py .
COPY real_policies_final.csv .

# 비 루트 사용자 생성
RUN useradd -m -u 1001 appuser && \
    chown -R appuser:appuser /app

USER appuser

# 포트 노출
EXPOSE 8000

# Uvicorn으로 FastAPI 서버 실행
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
