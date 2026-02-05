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

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs (must be at least 2 in different AZs)"
  type        = list(string)
}

variable "target_instance_ids" {
  description = "List of EC2 instance IDs to attach to target group"
  type        = list(string)
}

variable "target_port" {
  description = "Port on which targets receive traffic"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/actuator/health"
}

variable "certificate_arn" {
  description = "ARN of ACM certificate for HTTPS listener"
  type        = string
  default     = ""
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}
