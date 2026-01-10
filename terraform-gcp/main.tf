############################
# VPC NETWORKING
############################

resource "google_compute_network" "vpc" {
  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_name}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.0.0/24"
}

############################
# IAM SERVICE ACCOUNT
############################

resource "google_service_account" "cloudrun" {
  account_id   = "${var.project_name}-cr-sa"
  display_name = "Cloud Run Service Account"
}

resource "google_project_iam_member" "cloudrun_secret_access" {
  role   = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.cloudrun.email}"
}

############################
# SECRET MANAGER
############################

resource "google_secret_manager_secret" "app_secret" {
  secret_id = "${var.project_name}-app-secret"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "app_secret_v1" {
  secret      = google_secret_manager_secret.app_secret.id
  secret_data = var.app_secret_value
}

############################
# CLOUD RUN - FRONTEND
############################

resource "google_cloud_run_service" "frontend" {
  name     = "${var.project_name}-frontend"
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.cloudrun.email

      containers {
        image = var.frontend_image

        ports {
          container_port = 3000
        }

        env {
          name = "APP_SECRET"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.app_secret.secret_id
              key  = "latest"
            }
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "frontend_public" {
  service  = google_cloud_run_service.frontend.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

############################
# CLOUD RUN - BACKEND
############################

resource "google_cloud_run_service" "backend" {
  name     = "${var.project_name}-backend"
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.cloudrun.email

      containers {
        image = var.backend_image

        ports {
          container_port = 8000
        }

        env {
          name = "APP_SECRET"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.app_secret.secret_id
              key  = "latest"
            }
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "backend_public" {
  service  = google_cloud_run_service.backend.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}
