# AI 서버 빠른 배포 가이드

## 🚀 한 줄 명령어로 배포하기

### 방법 1: 자동 배포 스크립트 (권장)

```bash
# 실행 권한 부여
chmod +x deploy.sh

# 배포 실행
./deploy.sh
```

스크립트가 자동으로:
- ✅ 환경 변수 확인
- ✅ 필수 파일 확인
- ✅ Docker 상태 확인
- ✅ 이미지 빌드 및 실행
- ✅ 서버 헬스체크

### 방법 2: 수동 배포

```bash
# 1. 환경 변수 설정
cp .env.example .env
nano .env  # GEMINI_API_KEY 입력

# 2. Docker 빌드 및 실행
docker-compose up -d --build

# 3. 로그 확인
docker-compose logs -f ai-server
```

---

## 📋 필수 준비사항

1. **Gemini API 키 발급**
   - https://ai.google.dev/ 접속
   - API 키 생성
   - `.env` 파일에 추가

2. **백엔드 서버 주소**
   - 현재: `http://43.200.164.71:3000`
   - `.env`의 `BACKEND_API_URL` 확인

---

## 🔍 배포 확인

### 1. Health Check

```bash
curl http://localhost:8000/health
```

### 2. API 문서

브라우저에서:
```
http://YOUR_SERVER_IP/docs
```

### 3. 로그 확인

```bash
docker-compose logs -f ai-server
```

---

## 🛠️ 주요 명령어

| 작업 | 명령어 |
|------|--------|
| 서버 시작 | `docker-compose up -d` |
| 서버 중지 | `docker-compose down` |
| 서버 재시작 | `docker-compose restart ai-server` |
| 로그 확인 | `docker-compose logs -f ai-server` |
| 상태 확인 | `docker-compose ps` |
| 재배포 | `docker-compose down && docker-compose up -d --build` |

---

## 📚 자세한 가이드

전체 배포 가이드는 `AWS_DEPLOYMENT_GUIDE.md` 참고

---

## 💡 문제 해결

### BERT 모델 로딩 실패
```bash
# Swap 메모리 추가 (메모리 부족 시)
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### 포트 충돌
```bash
# 사용 중인 프로세스 확인
sudo lsof -i :8000

# 프로세스 종료
sudo kill -9 <PID>
```

### Gemini API 오류
```bash
# .env 파일 확인
cat .env

# 재시작
docker-compose restart ai-server
```

---

## 📞 지원

문제가 발생하면:
1. `docker-compose logs ai-server` 로그 확인
2. `AWS_DEPLOYMENT_GUIDE.md` 문제 해결 섹션 참고
