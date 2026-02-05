# CEOS Terraform 빠른 시작

## 1. 사전 준비

```bash
# Terraform 설치 (macOS)
brew install terraform

# AWS CLI 설정
aws configure
# AWS Access Key ID: [입력]
# AWS Secret Access Key: [입력]
# Default region name: ap-northeast-2

# EC2 키페어 생성
aws ec2 create-key-pair \
  --key-name ceos-21st-key \
  --query 'KeyMaterial' \
  --output text > ceos-21st-key.pem
chmod 400 ceos-21st-key.pem
```

## 2. 변수 파일 생성

```bash
cd generations
mkdir -p 21st
cp template/dev.tfvars.example 21st/dev.tfvars
vi 21st/dev.tfvars
```

**필수 수정 항목:**
```hcl
generation          = "21st"
ec2_ami_id          = "ami-xxxxxxxxx"
ec2_key_name        = "ceos-21st-key"
rds_master_password = "YourSecurePassword123!"
```

**최신 Ubuntu AMI ID 확인:**
```bash
aws ec2 describe-images --region ap-northeast-2 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
  --output text
```

## 3. Dev 환경 배포

```bash
cd environments/dev
terraform init
terraform plan -var-file="../../generations/21st/dev.tfvars"
terraform apply -var-file="../../generations/21st/dev.tfvars"
```

## 4. 출력값 확인

```bash
terraform output
terraform output github_secrets
terraform output route53_name_servers
```

## 5. 도메인 설정 (최초 1회)

1. `terraform output route53_name_servers` 값 확인
2. 도메인 등록소 (가비아 등) 로그인
3. 도메인 관리 → 네임서버 설정
4. NS 레코드를 출력값으로 변경

## 6. Backend 레포 GitHub Secrets 설정

Settings → Secrets and variables → Actions에서 추가:

| Secret | 값 |
|--------|-----|
| `EC2_HOST_DEV` | terraform output에서 확인 |
| `EC2_KEY_DEV` | `cat ceos-21st-key.pem` |
| `RDS_HOST_DEV` | terraform output에서 확인 |
| `RDS_PORT_DEV` | 3306 |
| `RDS_DATABASE_DEV` | terraform output에서 확인 |
| `RDS_USERNAME_DEV` | terraform output에서 확인 |
| `RDS_PASSWORD_DEV` | dev.tfvars의 rds_master_password |
| `S3_BUCKET_DEV` | terraform output에서 확인 |

## 7. 배포 확인

```bash
# EC2 접속
ssh -i ceos-21st-key.pem ubuntu@<EC2_PUBLIC_IP>

# 컨테이너 확인
docker ps

# API 테스트
curl https://dev.ceos-sinchon.com/actuator/health
```

## 8. Test 환경 배포

```bash
cd ../test
terraform init
terraform plan -var-file="../../generations/21st/dev.tfvars"
terraform apply -var-file="../../generations/21st/dev.tfvars"
```

---

## 체크리스트

### 인프라
- [ ] EC2 SSH 접속 가능
- [ ] Docker 설치 확인
- [ ] RDS Endpoint 확인 (Dev만)
- [ ] S3 버킷 생성 확인
- [ ] ALB 접속 가능

### Backend 레포
- [ ] GitHub Secrets 설정 완료
- [ ] GitHub Actions 배포 성공
- [ ] `https://dev.ceos-sinchon.com` 접속 확인
