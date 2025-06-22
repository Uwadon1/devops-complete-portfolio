# Production environment outputs

output "environment" {
  description = "Environment name"
  value       = "prod"
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = module.webapp.cluster_name
}

output "service_name" {
  description = "ECS service name"
  value       = module.webapp.service_name
}

output "log_group_name" {
  description = "CloudWatch log group"
  value       = module.webapp.log_group_name
}

output "autoscaling_enabled" {
  description = "Auto scaling status"
  value       = "enabled"
}

output "console_urls" {
  description = "AWS console URLs"
  value = {
    ecs_cluster = "https://console.aws.amazon.com/ecs/home?region=${var.aws_region}#/clusters/${module.webapp.cluster_name}"
    logs        = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/${replace(module.webapp.log_group_name, "/", "%2F")}"
    autoscaling = "https://console.aws.amazon.com/ecs/home?region=${var.aws_region}#/clusters/${module.webapp.cluster_name}/services/${module.webapp.service_name}/autoscaling"
  }
}

output "next_steps" {
  description = "What to do next"
  value = <<EOF
Production environment deployed successfully!

Key features:
- 2 instances running (with auto-scaling 2-10)
- 30-day log retention
- Production-optimized resource allocation

Next steps:
1. Check ECS console: ${local.console_urls.ecs_cluster}
2. Monitor auto-scaling: ${local.console_urls.autoscaling}
3. View logs: ${local.console_urls.logs}
4. Find your tasks' public IPs in the ECS console
5. Test load balancing across multiple instances

Production best practices enabled:
✅ Multiple instances for high availability
✅ Auto-scaling based on CPU and memory
✅ Conservative deployment strategy
✅ Extended log retention
EOF
}

locals {
  console_urls = {
    ecs_cluster = "https://console.aws.amazon.com/ecs/home?region=${var.aws_region}#/clusters/${module.webapp.cluster_name}"
    logs        = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/${replace(module.webapp.log_group_name, "/", "%2F")}"
    autoscaling = "https://console.aws.amazon.com/ecs/home?region=${var.aws_region}#/clusters/${module.webapp.cluster_name}/services/${module.webapp.service_name}/autoscaling"
  }
}