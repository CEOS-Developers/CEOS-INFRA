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

variable "bucket_suffix" {
  description = "S3 bucket suffix"
  type        = string
  default     = "storage"
}

variable "enable_versioning" {
  description = "Enable S3 versioning"
  type        = bool
  default     = false
}

variable "block_public_access" {
  description = "Block public access (set to false if you need public bucket policy)"
  type        = bool
  default     = true
}

variable "enable_public_access" {
  description = "Enable public read/write access via bucket policy"
  type        = bool
  default     = false
}

variable "enable_cors" {
  description = "Enable CORS"
  type        = bool
  default     = true
}

variable "cors_allowed_origins" {
  description = "CORS allowed origins"
  type        = list(string)
  default     = ["*"]
}

variable "enable_lifecycle_rules" {
  description = "Enable lifecycle rules"
  type        = bool
  default     = false
}

variable "lifecycle_expiration_days" {
  description = "Lifecycle expiration days"
  type        = number
  default     = 365
}
