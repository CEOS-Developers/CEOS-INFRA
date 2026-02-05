# ==============================================
# VPC Module
# ==============================================
module "vpc" {
  source = "../../modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  generation         = var.generation
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  enable_nat_gateway = false # 비용 절감: EC2가 public subnet에 있어 불필요
}

# ==============================================
# EC2 Module (MySQL, Redis는 Docker로 실행)
# ==============================================
module "ec2" {
  source = "../../modules/ec2"

  project_name     = var.project_name
  environment      = var.environment
  generation       = var.generation
  vpc_id           = module.vpc.vpc_id
  vpc_cidr         = module.vpc.vpc_cidr
  subnet_id        = module.vpc.public_subnet_ids[0]
  ami_id           = var.ec2_ami_id
  instance_type    = var.ec2_instance_type
  key_name         = var.ec2_key_name
  root_volume_size = var.ec2_root_volume_size

  # ALB 사용 시 Elastic IP 불필요 (ALB DNS로 접근)
  enable_elastic_ip = !var.enable_alb

  # ALB에서만 8080 포트 접근 허용
  ssh_allowed_cidrs = var.ssh_allowed_cidrs

  user_data = templatefile("${path.module}/user-data.sh", {
    docker_username = var.docker_username
  })
}

# ==============================================
# ALB Module (Application Load Balancer)
# ==============================================
module "alb" {
  source = "../../modules/alb"
  count  = var.enable_alb ? 1 : 0

  project_name = var.project_name
  environment  = var.environment
  generation   = var.generation

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids # ALB는 2개 이상의 AZ 필요

  target_instance_ids = [module.ec2.instance_id]
  target_port         = 8080
  health_check_path   = var.health_check_path

  certificate_arn = var.enable_alb ? module.acm[0].certificate_arn : ""

  enable_deletion_protection = false
}

# ==============================================
# ACM Module (SSL Certificate)
# ==============================================
module "acm" {
  source = "../../modules/acm"
  count  = var.enable_alb ? 1 : 0

  project_name = var.project_name
  environment  = var.environment
  generation   = var.generation

  domain_name               = var.domain_name
  subject_alternative_names = ["${var.subdomain}.${var.domain_name}"]

  route53_zone_id        = module.route53[0].zone_id
  create_route53_records = true
}

# ==============================================
# Route 53 Module (DNS)
# ==============================================
module "route53" {
  source = "../../modules/route53"
  count  = var.enable_alb ? 1 : 0

  project_name = var.project_name
  environment  = var.environment
  generation   = var.generation

  domain_name        = var.domain_name
  create_hosted_zone = var.create_route53_zone
  zone_id            = var.route53_zone_id # 기존 zone 사용 시

  # ALB A 레코드는 아래 별도 리소스로 분리 (순환 참조 방지)
  alb_records = {}

  # SES DKIM (SES 모듈에서 토큰 가져옴)
  ses_dkim_tokens = var.enable_ses_dkim ? module.ses.dkim_tokens : {}

  # Netlify 등 외부 서비스 CNAME
  custom_cname_records = var.custom_cname_records
}

# ==============================================
# ALB A Record (Route53 모듈 분리로 순환 참조 방지)
# ==============================================
resource "aws_route53_record" "alb_alias" {
  count   = var.enable_alb ? 1 : 0
  zone_id = module.route53[0].zone_id
  name    = "${var.subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = module.alb[0].alb_dns_name
    zone_id                = module.alb[0].alb_zone_id
    evaluate_target_health = true
  }
}

# ==============================================
# S3 Module
# ==============================================
module "s3" {
  source = "../../modules/s3"

  project_name = var.project_name
  environment  = var.environment
  generation   = var.generation

  enable_versioning    = false # Dev에서는 versioning 비활성화
  enable_cors          = true
  cors_allowed_origins = var.s3_cors_allowed_origins
  block_public_access  = false
  enable_public_access = true
}

# ==============================================
# SES Module
# ==============================================
module "ses" {
  source = "../../modules/ses"

  project_name = var.project_name
  environment  = var.environment
  generation   = var.generation

  email_identities = var.ses_email_identities
  domain_identity  = var.ses_domain_identity
}
