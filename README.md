# CEOS Backend IAC

CEOS 백엔드 AWS 인프라를 Terraform으로 관리합니다.

## 구조

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Infra 레포 (현재)                            │
│  - Terraform으로 AWS 인프라 생성                                     │
│  - terraform apply 실행                                              │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ terraform output 값들
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         Backend 레포                                 │
│  - 애플리케이션 소스 코드                                             │
│  - GitHub Actions로 EC2에 배포                                       │
│  - GitHub Secrets에 인프라 정보 저장                                  │
└─────────────────────────────────────────────────────────────────────┘
```

## 환경 구분

| 폴더명 | 도메인 | 용도 | 인프라 |
|--------|--------|------|--------|
| `dev` | `dev.ceos-sinchon.com` | 메인 운영 환경 | EC2 + RDS + ALB |
| `test` | `test.ceos-sinchon.com` | 테스트 환경 | EC2 (Docker All-in-One) |

> **참고**: `dev` 환경이 실제 운영 환경입니다.

## 디렉토리 구조

```
├── modules/                    # Terraform 모듈
│   ├── vpc/                   # VPC, 서브넷
│   ├── ec2/                   # EC2 인스턴스
│   ├── rds/                   # MySQL RDS
│   ├── s3/                    # S3 버킷
│   ├── ses/                   # SES 이메일
│   ├── alb/                   # Application Load Balancer
│   ├── acm/                   # SSL 인증서
│   └── route53/               # DNS
├── environments/              # 환경별 설정
│   ├── dev/                   # dev.ceos-sinchon.com
│   └── test/                  # test.ceos-sinchon.com
├── generations/               # 기수별 설정
│   ├── template/              # 템플릿
│   └── 21st/                  # 21기 설정
└── scripts/                   # 마이그레이션 스크립트
```

---

## 빠른 시작

자세한 명령어는 [QUICKSTART.md](./QUICKSTART.md) 참고

### 1. 사전 준비

```bash
# Terraform 설치 확인
terraform version  # 1.0+ 필요

# AWS CLI 설정
aws configure
```

### 2. 변수 파일 생성

```bash
cd generations
mkdir -p 21st
cp template/dev.tfvars.example 21st/dev.tfvars
vi 21st/dev.tfvars
```

필수 수정 항목:
```hcl
generation          = "21st"
ec2_ami_id          = "ami-xxxxxxxxx"  # 최신 Ubuntu AMI
ec2_key_name        = "ceos-21st-key"
rds_master_password = "SecurePassword123!"
```

### 3. 배포

```bash
cd environments/dev
terraform init
terraform plan -var-file="../../generations/21st/dev.tfvars"
terraform apply -var-file="../../generations/21st/dev.tfvars"
```

### 4. 출력값 확인

```bash
terraform output github_secrets
terraform output route53_name_servers
```

### 5. 도메인 설정 (최초 1회)

도메인 등록소(가비아 등)에서 NS 레코드를 `route53_name_servers` 출력값으로 변경

---

## 아키텍처

### Dev 환경 (`dev.ceos-sinchon.com`)

```
Internet → Route 53 → ALB (HTTPS) → EC2 (Docker: App + Redis)
                                      ↓
                                    RDS MySQL (Private Subnet)
```

### Test 환경 (`test.ceos-sinchon.com`)

```
Internet → Route 53 → ALB (HTTPS) → EC2 (Docker: App + MySQL + Redis)
```

---

## GitHub Secrets 설정

Backend 레포 Settings → Secrets and variables → Actions에서 설정

### Dev 환경

| Terraform Output | GitHub Secret | 비고 |
|-----------------|---------------|------|
| - | `ENV_DEV` | .env 파일 전체 내용 (인수인계 자료 참고) |
| `terraform output -raw ec2_public_ip` | `EC2_HOST_DEV` | EC2 Public IP |
| `cat ceos-21st-key.pem` | `EC2_KEY_DEV` | SSH Private Key (수동) |

### Test 환경

| Terraform Output | GitHub Secret | 비고 |
|-----------------|---------------|------|
| - | `ENV_PROD` | .env 파일 전체 내용 (인수인계 자료 참고) |
| `terraform output -raw ec2_public_ip` | `EC2_HOST_PROD` | EC2 Public IP |
| `cat ceos-21st-key.pem` | `EC2_KEY_PROD` | SSH Private Key (수동) |

---

## 기수 이동 (마이그레이션)

### 1. 새 AWS 계정 준비

```bash
# 새 계정 IAM 사용자 생성 후 Access Key 발급
aws configure --profile ceos-22nd

# EC2 키페어 생성
export AWS_PROFILE=ceos-22nd
aws ec2 create-key-pair \
  --key-name ceos-22nd-key \
  --region ap-northeast-2 \
  --query 'KeyMaterial' \
  --output text > ceos-22nd-key.pem
chmod 400 ceos-22nd-key.pem
```

### 2. 설정 파일 생성

```bash
cd generations
mkdir -p 22nd
cp template/dev.tfvars.example 22nd/dev.tfvars
vi 22nd/dev.tfvars  # generation을 "22nd"로 변경
```

### 3. 새 계정에 배포

```bash
export AWS_PROFILE=ceos-22nd
cd environments/dev
terraform init
terraform apply -var-file="../../generations/22nd/dev.tfvars"
```

### 4. 데이터 마이그레이션

```bash
cd scripts
cp migration-config.env.example migration-config.env
vi migration-config.env  # 이전/새 계정 정보 입력

# RDS 데이터 마이그레이션
./migrate-rds.sh export
./migrate-rds.sh import

# S3 데이터 마이그레이션
AWS_PROFILE=ceos-21st aws s3 sync s3://ceos-storage-dev-21st ./s3_backup/
AWS_PROFILE=ceos-22nd aws s3 sync ./s3_backup/ s3://ceos-storage-dev-22nd/
```

### 5. 도메인 전환

```bash
terraform output route53_name_servers
# 도메인 등록소에서 NS 레코드 변경
```

### 6. Backend 레포 GitHub Secrets 업데이트

```bash
terraform output github_secrets
# 출력된 값들을 Backend 레포 GitHub Secrets에 설정
```

### 7. 이전 계정 정리 (안정화 후)

```bash
export AWS_PROFILE=ceos-21st
cd environments/dev
terraform destroy -var-file="../../generations/21st/dev.tfvars"
```

---

## 주요 명령어

```bash
# 초기화
terraform init

# 계획 확인
terraform plan -var-file="../../generations/21st/dev.tfvars"

# 배포
terraform apply -var-file="../../generations/21st/dev.tfvars"

# 출력값 확인
terraform output
terraform output github_secrets
terraform output route53_name_servers

# 리소스 삭제
terraform destroy -var-file="../../generations/21st/dev.tfvars"

# 특정 리소스만 재생성
terraform taint module.ec2.aws_instance.main
terraform apply -var-file="../../generations/21st/dev.tfvars"
```

---

## SES 이메일 설정

### Terraform으로 자동화되는 부분

- SES 도메인 Identity 생성
- DKIM 키 생성 및 Route53 DNS 레코드 등록
- SPF 레코드, MX 레코드
- Configuration Set

### 수동으로 해야 하는 부분

**Sandbox 해제 요청** (AWS Console > SES > Account dashboard > Request production access)

```
Mail type: Transactional
Website URL: https://ceos-sinchon.com
Use case: University startup club sending application confirmations and notifications
```

---


## 관련 문서

- [QUICKSTART.md](./QUICKSTART.md) - 명령어 중심 빠른 시작 가이드
- [generations/README.md](./generations/README.md) - 기수별 설정 가이드
