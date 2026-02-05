output "email_identities" {
  description = "Verified email identities"
  value       = aws_ses_email_identity.main[*].email
}

output "domain_identity" {
  description = "Domain identity"
  value       = var.domain_identity != "" ? aws_ses_domain_identity.main[0].domain : null
}

output "domain_identity_arn" {
  description = "Domain identity ARN"
  value       = var.domain_identity != "" ? aws_ses_domain_identity.main[0].arn : null
}

output "domain_dkim_tokens" {
  description = "DKIM tokens for domain verification (list)"
  value       = var.domain_identity != "" ? aws_ses_domain_dkim.main[0].dkim_tokens : []
}

output "dkim_tokens" {
  description = "DKIM tokens as map for Route 53 records"
  value = var.domain_identity != "" ? {
    for token in aws_ses_domain_dkim.main[0].dkim_tokens : token => token
  } : {}
}

output "configuration_set_name" {
  description = "SES configuration set name"
  value       = aws_ses_configuration_set.main.name
}
