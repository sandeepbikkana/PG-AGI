variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type    = string
  default = "asia-south1"
}

variable "project_name" {
  type    = string
  default = "pg-agi"
}

variable "frontend_image" {
  type        = string
  description = "Container image for frontend (Artifact Registry)"
}

variable "backend_image" {
  type        = string
  description = "Container image for backend (Artifact Registry)"
}

variable "app_secret_value" {
  type        = string
  sensitive   = true
  description = "Application secret value"
}
