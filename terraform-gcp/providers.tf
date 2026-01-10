terraform {
  required_version = ">= 1.5"

  backend "gcs" {
    bucket  = "pg-agi-terraform-state"
    prefix  = "cloudrun/dev"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
