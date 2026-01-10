variable "aws_region" {
  default = "ap-south-1"
}

variable "project_name" {
  default = "PG-AGI"
}

variable "frontend_image" {
  description = "ECR image for frontend"
}

variable "backend_image" {
  description = "ECR image for backend"
}
