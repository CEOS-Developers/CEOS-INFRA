# CEOS Generations - 기수별 설정

이 디렉토리는 **기수별 AWS 계정 설정**을 관리합니다.

## 디렉토리 구조

```
generations/
├── template/
│   ├── dev.tfvars.example    # Dev 환경 (운영) 템플릿
│   └── test.tfvars.example   # Test 환경 템플릿
├── 21st/
│   ├── dev.tfvars            # 21기 운영 설정 (gitignore)
│   └── test.tfvars           # 21기 테스트 설정 (gitignore)
└── README.md
```

## 새 기수 설정

### 1. 디렉토리 생성 및 템플릿 복사

```bash
cd generations
mkdir 22nd
cp template/dev.tfvars.example 22nd/dev.tfvars
```

### 2. 설정 파일 수정

```bash
vi 22nd/dev.tfvars
```

**필수 수정:**
```hcl
generation          = "22nd"
ec2_key_name        = "ceos-22nd-key"
ec2_ami_id          = "ami-xxxxxxxxx"  # 최신 확인
rds_master_password = "NewSecurePassword123!"
```

### 3. EC2 Key Pair 생성

```bash
aws ec2 create-key-pair \
  --key-name ceos-22nd-key \
  --region ap-northeast-2 \
  --query 'KeyMaterial' \
  --output text > ceos-22nd-key.pem
chmod 400 ceos-22nd-key.pem
```

### 4. 배포

```bash
cd ../environments/dev
terraform init
terraform plan -var-file="../../generations/22nd/dev.tfvars"
terraform apply -var-file="../../generations/22nd/dev.tfvars"
```

## 보안

### 커밋 금지
- `*.tfvars` (비밀번호 포함)
- `*.pem` (SSH 키)

### 커밋 허용
- `*.tfvars.example` (예제 파일)

## 최신 Ubuntu AMI ID 확인

```bash
aws ec2 describe-images --region ap-northeast-2 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
  --output text
```
