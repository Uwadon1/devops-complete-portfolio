# Production environment variables

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "container_image" {
  description = "Docker image to run"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 80
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "cpu" {
  description = "CPU allocation for the task"
  type        = string
  default     = "512"  # Higher CPU for production
}

variable "memory" {
  description = "Memory allocation for the task"
  type        = string
  default     = "1024"  # Higher memory for production
}

variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
  default     = 2  # Multiple instances for production
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30  # Longer retention for production
}

variable "enable_autoscaling" {
  description = "Enable auto scaling for the service"
  type        = bool
  default     = true  # Enable autoscaling in production
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks for auto scaling"
  type        = number
  default     = 2
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks for auto scaling"
  type        = number
  default     = 10
}

variable "autoscaling_cpu_target" {
  description = "Target CPU utilization for auto scaling"
  type        = number
  default     = 70
}

variable "autoscaling_memory_target" {
  description = "Target memory utilization for auto scaling"
  type        = number
  default     = 80
}

variable "max_capacity" {
  description = "Maximum percentage of tasks during deployment"
  type        = number
  default     = 150
}

variable "min_capacity" {
  description = "Minimum percentage of healthy tasks during deployment"
  type        = number
  default     = 75
} 