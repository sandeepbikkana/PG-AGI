output "frontend_url" {
  value = google_cloud_run_service.frontend.status[0].url
}

output "backend_url" {
  value = google_cloud_run_service.backend.status[0].url
}

output "service_account_email" {
  value = google_service_account.cloudrun.email
}
