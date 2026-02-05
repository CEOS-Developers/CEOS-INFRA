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
  default     = "t3.micro" # Prod: RDS 사용하므로 t3.micro
}

variable "ec2_key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "ec2_root_volume_size" {
  description = "EC2 root volume size in GB"
  type        = number
  default     = 20
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "docker_username" {
  description = "Docker Hub username"
  type        = string
}

# ==============================================
# RDS Variables
# ==============================================
variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "rds_database_name" {
  description = "RDS database name"
  type        = string
  default     = "ceos"
}

variable "rds_master_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

variable "rds_master_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "rds_publicly_accessible" {
  description = "Make RDS publicly accessible"
  type        = bool
  default     = false
}

variable "rds_skip_final_snapshot" {
  description = "Skip final snapshot when destroying RDS"
  type        = bool
  default     = false
}

# ==============================================
# ALB Variables
# ==============================================
variable "enable_alb" {
  description = "Enable Application Load Balancer"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Health check path for ALB target group"
  type        = string
  default     = "/actuator/health"
}

variable "alb_deletion_protection" {
  description = "Enable ALB deletion protection"
  type        = bool
  default     = true # Prod에서는 true 권장
}

# ==============================================
# Route 53 / Domain Variables
# ==============================================
variable "domain_name" {
  description = "Domain name (e.g., ceos-sinchon.com)"
  type        = string
}

variable "create_route53_zone" {
  description = "Create a new Route 53 hosted zone"
  type        = bool
  default     = true
}

variable "route53_zone_id" {
  description = "Existing Route 53 zone ID"
  type        = string
  default     = ""
}

variable "route53_alb_records" {
  description = "ALB A records to create (subdomain -> ALB)"
  type = map(object({
    alb_dns_name = string
    alb_zone_id  = string
  }))
  default = {}
}

variable "acm_subject_alternative_names" {
  description = "ACM Subject Alternative Names"
  type        = list(string)
  default     = []
}

variable "custom_cname_records" {
  description = "Custom CNAME records"
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
  description = "SES email identities"
  type        = list(string)
  default     = []
}

variable "ses_domain_identity" {
  description = "SES domain identity"
  type        = string
  default     = ""
}

variable "enable_ses_dkim" {
  description = "Enable SES DKIM records in Route 53"
  type        = bool
  default     = true
}

variable "ses_subdomain" {
  description = "Subdomain for SES MX/SPF records"
  type        = string
  default     = "ceos"
}
