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

variable "email_identities" {
  description = "List of email addresses to verify"
  type        = list(string)
  default     = []
}

variable "domain_identity" {
  description = "Domain to verify for SES"
  type        = string
  default     = ""
}
