output "frontend_url" {
  value = google_cloud_run_service.frontend.status[0].url
}

output "backend_url" {
  value = google_cloud_run_service.backend.status[0].url
}

output "service_account_email" {
  value = google_service_account.cloudrun.email
}

output "monitoring_dashboard_name" {
  value = google_monitoring_dashboard.cloudrun_dashboard.display_name
}

output "cpu_alert_policy" {
  value = google_monitoring_alert_policy.cloudrun_high_cpu.display_name
}
