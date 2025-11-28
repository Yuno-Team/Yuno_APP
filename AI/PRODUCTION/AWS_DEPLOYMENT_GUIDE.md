# Yuno AI 서버 AWS 배포 가이드

## 📋 목차
1. [사전 준비](#사전-준비)
2. [EC2 인스턴스 설정](#ec2-인스턴스-설정)
3. [서버 배포](#서버-배포)
4. [실행 및 테스트](#실행-및-테스트)
5. [모니터링 및 관리](#모니터링-및-관리)
6. [문제 해결](#문제-해결)

---

## 🔧 사전 준비

### 1. 필요한 것들
- ✅ AWS 계정 (유료)
- ✅ Gemini API 키 (https://ai.google.dev/)
- ✅ 백엔드 서버 IP 주소 (현재: `43.200.164.71`)
- ✅ SSH 키 페어 (.pem 파일)

### 2. 권장 EC2 스펙

| 항목 | 권장 사양 | 설명 |
|------|----------|------|
| 인스턴스 타입 | **t3.medium** 이상 | CPU 2코어, 메모리 4GB |
| 스토리지 | **20GB** 이상 | BERT 모델 + 데이터 + OS |
| OS | **Ubuntu 22.04 LTS** | 안정성 및 Docker 지원 |
| 리전 | **ap-northeast-2** (서울) | 낮은 레이턴시 |

**비용 예상**:
- t3.medium (서울): 약 $0.052/시간 = **월 $38**
- 스토리지 (20GB): 약 **월 $2**
- 총 예상 비용: **월 $40 정도**

---

## 🖥️ EC2 인스턴스 설정

### 1. EC2 인스턴스 생성

```bash
# AWS 콘솔에서 EC2 생성
1. EC2 대시보드 → "인스턴스 시작" 클릭
2. 이름: yuno-ai-server
3. AMI: Ubuntu Server 22.04 LTS
4. 인스턴스 타입: t3.medium
5. 키 페어: 새로 생성 또는 기존 사용
6. 네트워크 설정:
   - VPC: 기본값
   - 퍼블릭 IP 자동 할당: 활성화
7. 스토리지: 20GB gp3
8. 보안 그룹 설정 (아래 참고)
```

### 2. 보안 그룹 설정

| 타입 | 프로토콜 | 포트 | 소스 | 설명 |
|------|---------|------|------|------|
| SSH | TCP | 22 | 내 IP | SSH 접속 |
| HTTP | TCP | 80 | 0.0.0.0/0 | API 접근 |
| HTTPS | TCP | 443 | 0.0.0.0/0 | SSL API 접근 |
| Custom TCP | TCP | 8000 | 0.0.0.0/0 | AI API 직접 접근 (선택) |

### 3. Elastic IP 할당 (권장)

```bash
# 고정 IP 주소를 위해 Elastic IP 할당
1. EC2 → 탄력적 IP → "탄력적 IP 주소 할당"
2. 생성된 IP를 EC2 인스턴스에 연결
3. 이 IP를 프론트엔드에서 사용
```

---

## 🚀 서버 배포

### 1. SSH 접속

```bash
# Windows (Git Bash 또는 PowerShell)
ssh -i "your-key.pem" ubuntu@YOUR_EC2_PUBLIC_IP

# 예시
ssh -i "yuno-ai-key.pem" ubuntu@13.125.123.45
```

### 2. 시스템 업데이트 및 Docker 설치

```bash
# 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# Docker 설치
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER

# 재로그인 (필수)
exit
# 다시 SSH 접속
```

### 3. 프로젝트 파일 업로드

**방법 1: Git 사용 (권장)**

```bash
# EC2에서 실행
cd ~
git clone https://github.com/YOUR_USERNAME/Yuno_APP.git
cd Yuno_APP/AI/PRODUCTION
```

**방법 2: SCP 직접 업로드**

```bash
# 로컬 PC에서 실행 (Windows Git Bash)
cd C:/alpha_project/Yuno_APP/AI/PRODUCTION

# 필수 파일만 압축
tar -czf yuno-ai.tar.gz \
  main.py \
  yuno_ai_system_clean.py \
  real_policies_final.csv \
  requirements.txt \
  Dockerfile \
  docker-compose.yml \
  nginx/

# EC2로 업로드
scp -i "your-key.pem" yuno-ai.tar.gz ubuntu@YOUR_EC2_IP:~/

# EC2에서 압축 해제
ssh -i "your-key.pem" ubuntu@YOUR_EC2_IP
mkdir -p ~/yuno-ai && cd ~/yuno-ai
tar -xzf ~/yuno-ai.tar.gz
```

### 4. 환경 변수 설정

```bash
# EC2에서 실행
cd ~/yuno-ai  # 또는 ~/Yuno_APP/AI/PRODUCTION

# .env 파일 생성
nano .env
```

**.env 파일 내용:**
```bash
# Gemini API Key (필수)
GEMINI_API_KEY=your_actual_gemini_api_key_here

# 백엔드 API URL (백엔드 서버 주소로 변경)
BACKEND_API_URL=http://43.200.164.71:3000

# 환경
NODE_ENV=production
```

**Ctrl+O → Enter → Ctrl+X** 로 저장

### 5. Docker 이미지 빌드 및 실행

```bash
# Docker Compose로 빌드 및 실행
docker-compose up -d --build

# 로그 확인 (BERT 모델 로딩 약 4-5분 소요)
docker-compose logs -f ai-server

# 다음 메시지가 나오면 성공:
# "BERT Model Loaded: 2700 policies"
# "Server Ready!"
# "Uvicorn running on http://0.0.0.0:8000"
```

**Ctrl+C**로 로그 보기 종료 (서버는 백그라운드에서 계속 실행)

---

## ✅ 실행 및 테스트

### 1. Health Check

```bash
# EC2 내부에서 테스트
curl http://localhost:8000/health

# 예상 응답:
# {
#   "status": "healthy",
#   "model_loaded": true,
#   "total_policies": 2700,
#   "timestamp": "2025-11-28T..."
# }
```

```bash
# 외부에서 테스트 (로컬 PC)
curl http://YOUR_EC2_PUBLIC_IP/health

# 또는 브라우저에서
http://YOUR_EC2_PUBLIC_IP/health
```

### 2. API 문서 확인

브라우저에서:
```
http://YOUR_EC2_PUBLIC_IP/docs
```

### 3. AI 추천 테스트

```bash
curl -X POST http://YOUR_EC2_PUBLIC_IP/api/recommendations?top_k=3 \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "test_user",
    "age": 24,
    "major": "컴퓨터공학",
    "interests": ["취업", "창업"]
  }'
```

### 4. AI 요약 테스트

```bash
curl -X POST http://YOUR_EC2_PUBLIC_IP/api/summary \
  -H "Content-Type: application/json" \
  -d '{
    "policy_id": "20240703005400200002",
    "user_age": 24,
    "user_major": "컴퓨터공학"
  }'
```

---

## 🔄 프론트엔드 연동

### Flutter 앱 설정 변경

**파일: `FE/lib/services/ai_service.dart`**

```dart
class AIService {
  // 개발 환경
  // static const String baseUrl = 'http://localhost:8000';

  // 프로덕션 환경 (EC2 Public IP 또는 도메인)
  static const String baseUrl = 'http://YOUR_EC2_PUBLIC_IP';
  // 또는
  // static const String baseUrl = 'https://ai.yuno-app.com';

  ...
}
```

변경 후:
```bash
cd FE
flutter clean
flutter pub get
flutter run -d chrome
```

---

## 📊 모니터링 및 관리

### 1. 로그 확인

```bash
# AI 서버 로그
docker-compose logs -f ai-server

# Nginx 로그
docker-compose logs -f nginx

# 최근 100줄만 보기
docker-compose logs --tail=100 ai-server
```

### 2. 서버 상태 확인

```bash
# 컨테이너 상태
docker-compose ps

# 리소스 사용량
docker stats

# 디스크 사용량
df -h
```

### 3. 서버 재시작

```bash
# 전체 재시작
docker-compose restart

# AI 서버만 재시작
docker-compose restart ai-server

# 코드 변경 후 재배포
docker-compose down
docker-compose up -d --build
```

### 4. 서버 중지

```bash
# 컨테이너 중지 (데이터 유지)
docker-compose stop

# 컨테이너 삭제 (볼륨은 유지)
docker-compose down

# 완전 삭제 (볼륨 포함)
docker-compose down -v
```

### 5. 자동 재시작 설정 (완료됨)

docker-compose.yml에 이미 `restart: unless-stopped` 설정되어 있어서:
- EC2 재부팅 시 자동으로 컨테이너 시작
- 크래시 발생 시 자동 재시작

---

## 🐛 문제 해결

### 1. BERT 모델 로딩 실패

**증상**: "Failed to load AI model" 에러

**해결**:
```bash
# 메모리 부족일 가능성
# t3.medium으로 인스턴스 타입 변경
# 또는 swap 메모리 추가

sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 2. Gemini API 오류

**증상**: "Gemini API not configured"

**해결**:
```bash
# .env 파일 확인
cat .env

# GEMINI_API_KEY가 올바른지 확인
# 다시 설정 후 재시작
docker-compose restart ai-server
```

### 3. 포트 충돌

**증상**: "Port 8000 already in use"

**해결**:
```bash
# 포트 사용 중인 프로세스 확인
sudo lsof -i :8000

# 프로세스 종료
sudo kill -9 <PID>

# 또는 docker-compose.yml에서 포트 변경
# ports:
#   - "8001:8000"
```

### 4. 백엔드 연결 실패

**증상**: "Failed to fetch policy from backend"

**해결**:
```bash
# 백엔드 서버가 실행 중인지 확인
curl http://43.200.164.71:3000/health

# EC2 보안 그룹에서 백엔드로의 outbound 허용 확인
# .env의 BACKEND_API_URL 확인
```

### 5. 메모리 부족

**증상**: 서버가 느리거나 크래시

**해결**:
```bash
# 메모리 사용량 확인
free -h

# Swap 메모리 추가 (위 참고)
# 또는 t3.large로 업그레이드 (8GB RAM)
```

---

## 🔒 보안 설정 (권장)

### 1. SSH 포트 변경

```bash
sudo nano /etc/ssh/sshd_config
# Port 22 → Port 2222로 변경
sudo systemctl restart sshd

# 보안 그룹에서 2222 포트 추가
```

### 2. 방화벽 설정

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8000/tcp
sudo ufw enable
```

### 3. SSL 인증서 설정 (선택)

```bash
# Certbot 설치
sudo apt install certbot

# Let's Encrypt 인증서 발급
sudo certbot certonly --standalone -d your-domain.com

# Nginx 설정에서 SSL 활성화 (nginx.conf 주석 해제)
```

---

## 📈 성능 최적화

### 1. Workers 개수 조정

**Dockerfile 수정:**
```dockerfile
# 단일 워커 (기본)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]

# 멀티 워커 (t3.medium 이상)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
```

### 2. 캐시 최적화

이미 구현됨:
- 추천 결과 캐시 (메모리)
- 요약 결과 캐시 (메모리)
- 최대 1000개 캐시 유지

---

## 💰 비용 절감 팁

1. **Reserved Instance**: 1년 약정 시 최대 40% 할인
2. **Spot Instance**: 최대 90% 할인 (중단 가능)
3. **Auto Scaling**: 트래픽에 따라 자동 확장/축소
4. **CloudWatch 모니터링**: 무료 티어 활용

---

## 📝 체크리스트

배포 전:
- [ ] EC2 인스턴스 생성 (t3.medium, 20GB)
- [ ] 보안 그룹 설정 (22, 80, 443, 8000)
- [ ] Elastic IP 할당
- [ ] Gemini API 키 발급

배포 중:
- [ ] Docker 설치
- [ ] 프로젝트 파일 업로드
- [ ] .env 파일 설정
- [ ] docker-compose up -d --build

배포 후:
- [ ] Health check 성공
- [ ] API 문서 접근 가능
- [ ] AI 추천 테스트 성공
- [ ] AI 요약 테스트 성공
- [ ] 프론트엔드 연동 확인

---

## 🆘 도움말

- **AI 서버 로그**: `docker-compose logs -f ai-server`
- **Nginx 로그**: `docker-compose logs -f nginx`
- **컨테이너 재시작**: `docker-compose restart`
- **완전 재배포**: `docker-compose down && docker-compose up -d --build`

---

## 📚 참고 자료

- [AWS EC2 가격](https://aws.amazon.com/ko/ec2/pricing/)
- [Docker 공식 문서](https://docs.docker.com/)
- [FastAPI 배포 가이드](https://fastapi.tiangolo.com/deployment/)
- [Gemini API](https://ai.google.dev/)
