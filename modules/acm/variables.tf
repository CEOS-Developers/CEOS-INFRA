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
  description = "Primary domain name for the certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "Subject Alternative Names (SANs) for the certificate"
  type        = list(string)
  default     = []
}

variable "route53_zone_id" {
  description = "Route 53 Hosted Zone ID for DNS validation"
  type        = string
  default     = ""
}

variable "create_route53_records" {
  description = "Create Route 53 records for certificate validation"
  type        = bool
  default     = true
}
