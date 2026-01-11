output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "cloudwatch_dashboard" {
  value = aws_cloudwatch_dashboard.ecs.dashboard_name
}

output "alert_topic_arn" {
  value = aws_sns_topic.alerts.arn
}
