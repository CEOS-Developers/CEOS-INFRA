variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, prod)"
  type        = string
}

variable "generation" {
  description = "CEOS generation"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "create_hosted_zone" {
  description = "Create a new hosted zone"
  type        = bool
  default     = false
}

variable "zone_id" {
  description = "Existing Route 53 zone ID (required if create_hosted_zone is false)"
  type        = string
  default     = ""
}

variable "alb_records" {
  description = "Map of subdomain to ALB DNS name and zone ID"
  type = map(object({
    alb_dns_name = string
    alb_zone_id  = string
  }))
  default = {}
}

variable "ses_dkim_tokens" {
  description = "SES DKIM tokens for domain verification"
  type        = map(string)
  default     = {}
}

variable "ses_subdomain" {
  description = "Subdomain for SES MX and SPF records"
  type        = string
  default     = "ceos"
}

variable "create_ses_mx_record" {
  description = "Create MX record for SES"
  type        = bool
  default     = false
}

variable "create_ses_spf_record" {
  description = "Create SPF TXT record for SES"
  type        = bool
  default     = false
}

variable "aws_region" {
  description = "AWS region for SES"
  type        = string
  default     = "ap-northeast-2"
}

variable "custom_cname_records" {
  description = "Custom CNAME records (e.g., for Netlify, ACM validation)"
  type = map(object({
    value = string
    ttl   = number
  }))
  default = {}
}
