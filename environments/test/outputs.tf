# ==============================================
# CEOS Infrastructure Outputs (Test Environment)
# test.ceos-sinchon.com
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
    EC2_HOST_TEST   = module.ec2.public_ip
    S3_BUCKET_TEST  = module.s3.bucket_name
    SES_DOMAIN_TEST = var.domain_name
  }
}

output "application_url" {
  description = "애플리케이션 URL"
  value       = var.enable_alb ? "https://${var.subdomain}.${var.domain_name}" : "http://${module.ec2.public_ip}"
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
# Docker 환경 정보 (Test 환경은 Docker All-in-One)
# ==============================================
output "docker_info" {
  description = "Test 환경 Docker 정보 (MySQL, Redis가 Docker로 실행됨)"
  value = {
    note       = "Test 환경은 MySQL과 Redis가 Docker 컨테이너로 실행됩니다."
    mysql_host = "mysql (docker container)"
    mysql_port = "3306"
    redis_host = "redis (docker container)"
    redis_port = "6379"
  }
}
