#!/bin/bash

# Yuno AI 서버 배포 스크립트
# 사용법: ./deploy.sh

set -e  # 에러 발생 시 즉시 중단

echo "=================================================="
echo "Yuno AI 서버 배포 시작"
echo "=================================================="

# 색상 코드
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 1. 환경 변수 확인
echo ""
echo "${YELLOW}[1/6] 환경 변수 확인 중...${NC}"
if [ ! -f .env ]; then
    echo "${RED}에러: .env 파일이 없습니다!${NC}"
    echo "먼저 .env.example을 복사하여 .env를 만들고 값을 설정하세요:"
    echo "  cp .env.example .env"
    echo "  nano .env"
    exit 1
fi

# GEMINI_API_KEY 확인
if ! grep -q "GEMINI_API_KEY=.*[^[:space:]]" .env; then
    echo "${RED}에러: .env에 GEMINI_API_KEY가 설정되지 않았습니다!${NC}"
    exit 1
fi

echo "${GREEN}✓ 환경 변수 확인 완료${NC}"

# 2. 필수 파일 확인
echo ""
echo "${YELLOW}[2/6] 필수 파일 확인 중...${NC}"
required_files=("main.py" "yuno_ai_system_clean.py" "real_policies_final.csv" "requirements.txt" "Dockerfile" "docker-compose.yml")
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "${RED}에러: $file 파일이 없습니다!${NC}"
        exit 1
    fi
    echo "  ✓ $file"
done
echo "${GREEN}✓ 필수 파일 확인 완료${NC}"

# 3. Docker 실행 확인
echo ""
echo "${YELLOW}[3/6] Docker 확인 중...${NC}"
if ! command -v docker &> /dev/null; then
    echo "${RED}에러: Docker가 설치되지 않았습니다!${NC}"
    echo "다음 명령으로 Docker를 설치하세요:"
    echo "  curl -fsSL https://get.docker.com -o get-docker.sh"
    echo "  sudo sh get-docker.sh"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "${RED}에러: Docker가 실행 중이 아닙니다!${NC}"
    echo "다음 명령으로 Docker를 시작하세요:"
    echo "  sudo systemctl start docker"
    exit 1
fi
echo "${GREEN}✓ Docker 확인 완료${NC}"

# 4. 이전 컨테이너 정리 (선택)
echo ""
echo "${YELLOW}[4/6] 이전 컨테이너 확인 중...${NC}"
if docker-compose ps | grep -q "yuno-ai-server"; then
    read -p "기존 컨테이너가 실행 중입니다. 중지하고 재배포하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "기존 컨테이너 중지 중..."
        docker-compose down
        echo "${GREEN}✓ 기존 컨테이너 중지 완료${NC}"
    else
        echo "배포를 취소합니다."
        exit 0
    fi
else
    echo "${GREEN}✓ 실행 중인 컨테이너 없음${NC}"
fi

# 5. Docker 이미지 빌드 및 실행
echo ""
echo "${YELLOW}[5/6] Docker 이미지 빌드 및 실행 중...${NC}"
echo "이 작업은 5-10분 정도 소요될 수 있습니다."
echo ""

docker-compose up -d --build

echo "${GREEN}✓ Docker 컨테이너 시작 완료${NC}"

# 6. 서버 시작 대기 및 헬스체크
echo ""
echo "${YELLOW}[6/6] 서버 시작 대기 중...${NC}"
echo "BERT 모델 로딩 중... (약 4-5분 소요)"

# 60초 동안 헬스체크 시도 (BERT 로딩 시간 고려)
max_attempts=120
attempt=0
while [ $attempt -lt $max_attempts ]; do
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo ""
        echo "${GREEN}✓ 서버가 성공적으로 시작되었습니다!${NC}"

        # 서버 정보 출력
        echo ""
        echo "=================================================="
        echo "서버 정보"
        echo "=================================================="
        echo "로컬 Health Check: http://localhost:8000/health"
        echo "로컬 API 문서: http://localhost:8000/docs"

        # Public IP 확인 (AWS EC2인 경우)
        if command -v ec2-metadata &> /dev/null; then
            PUBLIC_IP=$(ec2-metadata --public-ipv4 | cut -d " " -f 2)
            echo ""
            echo "외부 접속 URL:"
            echo "  Health Check: http://$PUBLIC_IP/health"
            echo "  API 문서: http://$PUBLIC_IP/docs"
        fi

        echo ""
        echo "로그 확인: docker-compose logs -f ai-server"
        echo "서버 중지: docker-compose down"
        echo "=================================================="
        exit 0
    fi

    # 진행 표시
    if [ $((attempt % 10)) -eq 0 ]; then
        echo -n "."
    fi

    attempt=$((attempt + 1))
    sleep 1
done

# 타임아웃
echo ""
echo "${RED}에러: 서버가 시작되지 않았습니다 (타임아웃)${NC}"
echo "로그를 확인하세요:"
echo "  docker-compose logs ai-server"
exit 1
