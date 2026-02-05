# ==============================================
# Common Variables
# ==============================================
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "ceos"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "generation" {
  description = "CEOS generation (e.g., 19th, 20th)"
  type        = string
}

# ==============================================
# VPC Variables
# ==============================================
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

# ==============================================
# EC2 Variables
# ==============================================
variable "ec2_ami_id" {
  description = "EC2 AMI ID (Ubuntu 22.04 LTS)"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small" # Docker로 MySQL, Redis도 실행하므로 t3.small 권장
}

variable "ec2_key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "ec2_root_volume_size" {
  description = "EC2 root volume size in GB"
  type        = number
  default     = 30 # MySQL 데이터 저장을 위해 30GB
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # 실제 사용 시 특정 IP로 제한 권장
}

variable "docker_username" {
  description = "Docker Hub username"
  type        = string
}

# ==============================================
# Database Variables (Docker MySQL for Dev)
# ==============================================
variable "db_username" {
  description = "Database username"
  type        = string
  default     = "ceos"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "ceos_dev"
}

# ==============================================
# ALB Variables
# ==============================================
variable "enable_alb" {
  description = "Enable Application Load Balancer"
  type        = bool
  default     = true # ALB 사용 (HTTPS 지원)
}

variable "health_check_path" {
  description = "Health check path for ALB target group"
  type        = string
  default     = "/actuator/health"
}

# ==============================================
# Route 53 / Domain Variables
# ==============================================
variable "domain_name" {
  description = "Domain name (e.g., ceos-sinchon.com)"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for this environment (e.g., dev, test)"
  type        = string
  default     = "dev"
}

variable "create_route53_zone" {
  description = "Create a new Route 53 hosted zone (set false if zone already exists)"
  type        = bool
  default     = true # 새 AWS 계정에서는 true
}

variable "route53_zone_id" {
  description = "Existing Route 53 zone ID (required if create_route53_zone is false)"
  type        = string
  default     = ""
}

variable "custom_cname_records" {
  description = "Custom CNAME records for external services (e.g., Netlify)"
  type = map(object({
    value = string
    ttl   = number
  }))
  default = {}
}

# ==============================================
# S3 Variables
# ==============================================
variable "s3_cors_allowed_origins" {
  description = "S3 CORS allowed origins"
  type        = list(string)
  default     = ["*"]
}

# ==============================================
# SES Variables
# ==============================================
variable "ses_email_identities" {
  description = "SES email identities to verify"
  type        = list(string)
  default     = []
}

variable "ses_domain_identity" {
  description = "SES domain identity for DKIM"
  type        = string
  default     = ""
}

variable "enable_ses_dkim" {
  description = "Enable SES DKIM records in Route 53"
  type        = bool
  default     = false
}
