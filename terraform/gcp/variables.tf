variable "project_id" {
  type        = string
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
  type = string
}

variable "backend_image" {
  type = string
}

variable "alert_email" {
  type        = string
  description = "Email address to receive alerts"
}
