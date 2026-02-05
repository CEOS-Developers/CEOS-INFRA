# Route 53 Hosted Zone
resource "aws_route53_zone" "main" {
  count = var.create_hosted_zone ? 1 : 0
  name  = var.domain_name

  tags = {
    Name        = "${var.project_name}-zone-${var.environment}"
    Environment = var.environment
    Generation  = var.generation
  }
}

# A Record for ALB
resource "aws_route53_record" "alb" {
  for_each = var.alb_records

  zone_id = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : var.zone_id
  name    = each.key
  type    = "A"

  alias {
    name                   = each.value.alb_dns_name
    zone_id                = each.value.alb_zone_id
    evaluate_target_health = true
  }
}

# CNAME Records for SES DKIM
resource "aws_route53_record" "ses_dkim" {
  for_each = var.ses_dkim_tokens

  zone_id = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : var.zone_id
  name    = "${each.key}._domainkey"
  type    = "CNAME"
  ttl     = 300
  records = ["${each.key}.dkim.amazonses.com"]
}

# MX Record for SES
resource "aws_route53_record" "ses_mx" {
  count = var.create_ses_mx_record ? 1 : 0

  zone_id = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : var.zone_id
  name    = var.ses_subdomain
  type    = "MX"
  ttl     = 300
  records = ["10 feedback-smtp.${var.aws_region}.amazonses.com"]
}

# TXT Record for SPF
resource "aws_route53_record" "ses_spf" {
  count = var.create_ses_spf_record ? 1 : 0

  zone_id = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : var.zone_id
  name    = var.ses_subdomain
  type    = "TXT"
  ttl     = 300
  records = ["v=spf1 include:amazonses.com ~all"]
}

# Custom CNAME Records
resource "aws_route53_record" "custom_cname" {
  for_each = var.custom_cname_records

  zone_id = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : var.zone_id
  name    = each.key
  type    = "CNAME"
  ttl     = each.value.ttl
  records = [each.value.value]
}
