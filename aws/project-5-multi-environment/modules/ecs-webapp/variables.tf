# Module variables

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

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
  default     = 3001
}

variable "cpu" {
  description = "CPU allocation for the task"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Memory allocation for the task"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum percentage of tasks during deployment"
  type        = number
  default     = 200
}

variable "min_capacity" {
  description = "Minimum percentage of healthy tasks during deployment"
  type        = number
  default     = 50
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "enable_autoscaling" {
  description = "Enable auto scaling for the service"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks for auto scaling"
  type        = number
  default     = 1
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