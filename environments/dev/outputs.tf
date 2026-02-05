# ==============================================
# CEOS Infrastructure Outputs (Dev Environment)
# dev.ceos-sinchon.com
# ==============================================
#
# 이 출력값들을 Backend 레포의 GitHub Secrets에 설정하세요.
# terraform output 명령어로 확인할 수 있습니다.
#

# ==============================================
# [중요] GitHub Secrets 설정 값
# ==============================================
output "github_secrets" {
  description = "Backend 레포 GitHub Secrets에 설정할 값들"
  value = {
    EC2_HOST_DEV     = module.ec2.public_ip
    RDS_HOST_DEV     = module.rds.db_instance_endpoint
    RDS_PORT_DEV     = module.rds.db_instance_port
    RDS_DATABASE_DEV = var.rds_database_name
    RDS_USERNAME_DEV = var.rds_master_username
    S3_BUCKET_DEV    = module.s3.bucket_name
    SES_DOMAIN_DEV   = var.domain_name
  }
}

output "application_url" {
  description = "애플리케이션 URL"
  value       = var.enable_alb ? "https://dev.${var.domain_name}" : "http://${module.ec2.public_ip}"
}

# ==============================================
# [중요] 도메인 설정
# ==============================================
output "route53_name_servers" {
  description = "도메인 등록소(가비아 등)에 설정할 네임서버 (NS 레코드)"
  value       = var.enable_alb && var.create_route53_zone ? module.route53[0].zone_name_servers : []
}

# ==============================================
# SSH 접속 정보
# ==============================================
output "ssh_connection" {
  description = "EC2 SSH 접속 명령어"
  value = {
    command   = "ssh -i ${var.ec2_key_name}.pem ubuntu@${module.ec2.public_ip}"
    public_ip = module.ec2.public_ip
  }
}

# ==============================================
# 인프라 상세 정보 (참고용)
# ==============================================
output "infrastructure_details" {
  description = "인프라 상세 정보"
  value = {
    vpc_id           = module.vpc.vpc_id
    ec2_instance_id  = module.ec2.instance_id
    alb_dns_name     = var.enable_alb ? module.alb[0].alb_dns_name : null
    route53_zone_id  = var.enable_alb ? module.route53[0].zone_id : null
    s3_bucket_arn    = module.s3.bucket_arn
    ses_identity_arn = module.ses.domain_identity_arn
  }
}

# ==============================================
# SES DKIM 설정 (이메일 인증)
# ==============================================
output "ses_dkim_tokens" {
  description = "SES DKIM tokens (Route53에 자동 설정됨)"
  value       = module.ses.dkim_tokens
}

# ==============================================
# 마이그레이션용 정보
# ==============================================
output "migration_info" {
  description = "계정 마이그레이션 시 필요한 정보"
  value = {
    rds_endpoint    = module.rds.db_instance_endpoint
    rds_database    = var.rds_database_name
    s3_bucket       = module.s3.bucket_name
    route53_zone_id = var.enable_alb ? module.route53[0].zone_id : null
    name_servers    = var.enable_alb && var.create_route53_zone ? module.route53[0].zone_name_servers : []
  }
}
