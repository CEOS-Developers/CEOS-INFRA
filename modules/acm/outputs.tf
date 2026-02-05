output "certificate_arn" {
  description = "ARN of the certificate"
  value       = aws_acm_certificate.main.arn
}

output "certificate_id" {
  description = "ID of the certificate"
  value       = aws_acm_certificate.main.id
}

output "certificate_domain_name" {
  description = "Domain name of the certificate"
  value       = aws_acm_certificate.main.domain_name
}

output "certificate_status" {
  description = "Status of the certificate"
  value       = aws_acm_certificate.main.status
}

output "validation_record_fqdns" {
  description = "FQDNs of validation records"
  value       = var.create_route53_records ? [for record in aws_route53_record.cert_validation : record.fqdn] : []
}
