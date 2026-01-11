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

############################
# CLOUD RUN - FRONTEND
############################

resource "google_cloud_run_service" "frontend" {
  name     = "${var.project_name}-frontend"
  location = var.region

  template {
    metadata {
      annotations = {
        # HARD COST SAFETY
        "autoscaling.knative.dev/maxScale" = "3"
      }
    }

    spec {
      service_account_name = google_service_account.cloudrun.email

      containers {
        image = var.frontend_image

        ports {
          container_port = 3000
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
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "3"
      }
    }

    spec {
      service_account_name = google_service_account.cloudrun.email

      containers {
        image = var.backend_image

        ports {
          container_port = 8000
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

## Dashboard
resource "google_monitoring_dashboard" "cloudrun_dashboard" {
  dashboard_json = jsonencode({
    displayName = "Cloud Run Overview"

    gridLayout = {
      columns = 2
      widgets = [

        # CPU USAGE
        {
          title = "CPU Utilization"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "metric.type=\"run.googleapis.com/container/cpu/utilizations\" resource.type=\"cloud_run_revision\""
                  aggregation = {
                    alignmentPeriod   = "60s"
                    perSeriesAligner  = "ALIGN_MEAN"
                  }
                }
              }
            }]
          }
        },

        # MEMORY USAGE
        {
          title = "Memory Utilization"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "metric.type=\"run.googleapis.com/container/memory/utilizations\" resource.type=\"cloud_run_revision\""
                  aggregation = {
                    alignmentPeriod   = "60s"
                    perSeriesAligner  = "ALIGN_MEAN"
                  }
                }
              }
            }]
          }
        },

        # REQUEST COUNT
        {
          title = "Request Count"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "metric.type=\"run.googleapis.com/request_count\" resource.type=\"cloud_run_revision\""
                  aggregation = {
                    alignmentPeriod   = "60s"
                    perSeriesAligner  = "ALIGN_SUM"
                  }
                }
              }
            }]
          }
        },

        # REQUEST LATENCY
        {
          title = "Request Latency (ms)"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "metric.type=\"run.googleapis.com/request_latencies\" resource.type=\"cloud_run_revision\""
                  aggregation = {
                    alignmentPeriod   = "60s"
                    perSeriesAligner  = "ALIGN_PERCENTILE_95"
                  }
                }
              }
            }]
          }
        }
      ]
    }
  })
}

## NOTIFICATIONS
resource "google_monitoring_notification_channel" "email" {
  display_name = "Email Alerts"
  type         = "email"

  labels = {
    email_address = var.alert_email
  }
}

## ALERTS
resource "google_monitoring_alert_policy" "cloudrun_high_cpu" {
  display_name = "Cloud Run High CPU (>70%)"

  combiner = "OR"

  conditions {
    display_name = "CPU Utilization > 70%"

    condition_threshold {
      filter = <<EOT
metric.type="run.googleapis.com/container/cpu/utilizations"
resource.type="cloud_run_revision"
EOT

      comparison      = "COMPARISON_GT"
      threshold_value = 0.7
      duration        = "300s"

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.email.id
  ]

  documentation {
    content  = "Cloud Run CPU utilization exceeded 70% for more than 5 minutes."
    mime_type = "text/markdown"
  }
}
