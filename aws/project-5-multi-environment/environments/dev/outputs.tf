# Development environment outputs

variable "aws_region" {
  description = "AWS region"
  type        = string
}

output "environment" {
  description = "Environment name"
  value       = "dev"
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

output "console_urls" {
  description = "AWS console URLs"
  value = {
    ecs_cluster = "https://console.aws.amazon.com/ecs/home?region=${var.aws_region}#/clusters/${module.webapp.cluster_name}"
    logs        = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/${replace(module.webapp.log_group_name, "/", "%2F")}"
  }
}

output "next_steps" {
  description = "What to do next"
  value = <<EOF
Development environment deployed successfully!

Next steps:
1. Check ECS console: ${local.console_urls.ecs_cluster}
2. View logs: ${local.console_urls.logs}
3. Find your task's public IP in the ECS console
4. Test your application: http://[PUBLIC_IP]

To get the public IP via CLI:
aws ecs list-tasks --cluster ${module.webapp.cluster_name} --service-name ${module.webapp.service_name}
EOF
}

locals {
  console_urls = {
    ecs_cluster = "https://console.aws.amazon.com/ecs/home?region=${var.aws_region}#/clusters/${module.webapp.cluster_name}"
    logs        = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/${replace(module.webapp.log_group_name, "/", "%2F")}"
  }
}