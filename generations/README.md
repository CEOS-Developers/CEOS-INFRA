# CEOS Generations - 기수별 AWS 계정 설정

이 디렉토리는 **기수별 AWS 계정 설정**을 관리합니다.

## 📁 디렉토리 구조

```
generations/
├── template/
│   ├── dev.tfvars.example    # Dev 환경 (운영) 템플릿
│   └── test.tfvars.example   # Test 환경 (테스트) 템플릿
│
├── 21st/
│   ├── dev.tfvars            # 21기 운영 환경 설정 (gitignore)
│   └── test.tfvars           # 21기 테스트 환경 설정 (gitignore)
│
├── 22nd/
│   ├── dev.tfvars            # 22기 운영 환경 설정 (gitignore)
│   └── test.tfvars           # 22기 테스트 환경 설정 (gitignore)
│
└── README.md                  # 이 파일
```

## 🚀 새 기수 AWS 계정 설정

### Step 1: 새 기수 디렉토리 생성

```bash
cd /path/to/CEOS-INFRA/generations

# 22기 디렉토리 생성
mkdir 22nd
cd 22nd
```

### Step 2: 템플릿 복사

```bash
# Dev 환경 (운영) 설정 파일 생성
cp ../template/dev.tfvars.example dev.tfvars

# Test 환경 (테스트) 설정 파일 생성 (선택)
cp ../template/test.tfvars.example test.tfvars
```

### Step 3: AWS 계정 정보 입력

```bash
# Dev 환경 설정 수정
vi dev.tfvars
```

**필수 수정 항목:**

```hcl
# 기수 이름 변경
generation = "22nd"  # ← 22nd로 변경

# EC2 SSH Key Pair 생성 필요 (아래 명령어 참고)
ec2_key_name = "ceos-22nd-key"

# Ubuntu 22.04 LTS AMI ID (최신으로 업데이트 권장)
ec2_ami_id = "ami-0c9c942bd7bf113a2"

# Docker Hub 계정명
docker_username = "ceossinchon"

# RDS 마스터 비밀번호 (보안상 반드시 변경!)
rds_master_password = "NewSecurePassword123!"

# 도메인 이름 (동일 유지)
domain_name = "ceos-sinchon.com"
```

### Step 4: EC2 SSH Key Pair 생성

```bash
# AWS CLI로 Key Pair 생성
aws ec2 create-key-pair \
  --key-name ceos-22nd-key \
  --region ap-northeast-2 \
  --query 'KeyMaterial' \
  --output text > ceos-22nd-key.pem

# 권한 설정
chmod 400 ceos-22nd-key.pem

# Key 파일은 안전한 곳에 보관 (절대 커밋하지 말 것!)
mv ceos-22nd-key.pem ~/.ssh/
```

### Step 5: Dev 환경 배포

```bash
cd ../../environments/dev

# Terraform 초기화
terraform init

# 변경 사항 미리보기
terraform plan -var-file="../../generations/22nd/dev.tfvars"

# 배포 (15-25분 소요)
terraform apply -var-file="../../generations/22nd/dev.tfvars"
```

### Step 6: 출력값 확인 및 Backend 레포 설정

```bash
# GitHub Secrets에 설정할 값 확인
terraform output github_secrets

# Route53 네임서버 확인 (도메인 등록소에 설정)
terraform output route53_name_servers
```

**Backend 레포 GitHub Secrets 설정:**
- Settings → Secrets and variables → Actions → New repository secret
- 위 출력값을 복사해서 각각 설정

---

## 🔄 기수 간 인프라 마이그레이션

### 시나리오: 21기 → 22기 인프라 이전

```bash
# 1. 22기 디렉토리 생성 및 설정 파일 복사
mkdir generations/22nd
cp generations/21st/dev.tfvars generations/22nd/dev.tfvars

# 2. 22기 설정 수정
vi generations/22nd/dev.tfvars
# generation = "22nd"
# ec2_key_name = "ceos-22nd-key"
# rds_master_password = "새로운비밀번호"

# 3. 22기 AWS 계정에 새 인프라 배포
export AWS_PROFILE=ceos-22nd  # 또는 aws configure
cd environments/dev
terraform init
terraform apply -var-file="../../generations/22nd/dev.tfvars"

# 4. 데이터 마이그레이션 (RDS, S3)
cd ../../scripts
./migrate-rds.sh export   # 21기 계정에서 데이터 추출
./migrate-rds.sh import   # 22기 계정으로 데이터 이전

# 5. Backend 레포 GitHub Secrets 업데이트
# 22기 인프라 정보로 교체

# 6. 도메인 NS 레코드 변경
# 가비아 등 도메인 등록소에서 NS 레코드를 22기 Route53으로 변경

# 7. 21기 인프라 정리 (확인 후)
export AWS_PROFILE=ceos-21st
cd environments/dev
terraform destroy -var-file="../../generations/21st/dev.tfvars"
```

자세한 마이그레이션 가이드는 `/MIGRATION.md` 참고

---

## 📋 환경별 차이점

### Dev 환경 (dev.ceos-sinchon.com) - 운영

```
✅ 사용자가 실제 접속하는 메인 환경
✅ RDS MySQL 사용 (db.t3.micro)
✅ EC2 t3.micro (App + Redis)
✅ ALB + HTTPS
✅ 자동 백업, 암호화
✅ 예상 비용: ~$43/월
```

### Test 환경 (test.ceos-sinchon.com) - 테스트

```
✅ 배포 전 테스트용 환경
✅ Docker MySQL 사용 (RDS 없음)
✅ EC2 t3.small (App + MySQL + Redis)
✅ ALB + HTTPS
✅ 예상 비용: ~$34/월
```

---

## 🔐 보안 주의사항

### ⚠️ 절대 커밋하면 안 되는 파일

```bash
# .gitignore에 이미 포함됨
generations/*/dev.tfvars      # 실제 설정 (비밀번호 포함)
generations/*/test.tfvars     # 실제 설정
*.pem                         # SSH 키
*.tfstate                     # Terraform 상태 파일
```

### ✅ 커밋해도 되는 파일

```bash
generations/template/*.tfvars.example  # 예제 파일 (비밀번호 없음)
generations/*/dev.tfvars.example       # 예제 파일
```

---

## 💡 팁

### 최신 Ubuntu AMI ID 찾기

```bash
aws ec2 describe-images \
  --region ap-northeast-2 \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].[ImageId,Name,CreationDate]' \
  --output table
```

### SSH 접속

```bash
ssh -i ~/.ssh/ceos-22nd-key.pem ubuntu@<EC2_PUBLIC_IP>
```

### 비용 최적화

- Test 환경은 필요할 때만 배포 (`terraform apply`)
- 사용 안 할 때는 삭제 (`terraform destroy`)
- Dev 환경은 항상 유지

---

## 🆘 문제 해결

### Q: terraform apply 시 "Module not installed" 에러

```bash
terraform init
```

### Q: ACM 인증서 검증이 10분 넘게 걸림

도메인 등록소에서 NS 레코드가 Route53으로 설정되었는지 확인:
```bash
dig NS ceos-sinchon.com
```

### Q: RDS 비밀번호를 잊어버렸어요

`generations/22nd/dev.tfvars` 파일에서 확인:
```bash
grep rds_master_password generations/22nd/dev.tfvars
```

### Q: 이전 기수 설정을 참고하고 싶어요

```bash
# 20기 설정 참고 (예제)
cat generations/20th/dev.tfvars.example
```

---
