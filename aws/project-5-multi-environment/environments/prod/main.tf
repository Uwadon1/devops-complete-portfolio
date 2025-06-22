# Production environment

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "prod"
      Project     = "multi-env-webapp"
      ManagedBy   = "terraform"
    }
  }
}

module "webapp" {
  source = "../../modules/ecs-webapp"

  environment     = "prod"
  app_name       = var.app_name
  aws_region     = var.aws_region
  container_image = var.container_image
  container_port = var.container_port

  # Production-specific settings
  cpu                = "512"     # More resources for prod
  memory            = "1024"
  desired_count     = 2          # Multiple instances for availability
  log_retention_days = 30        # Longer retention

  # Production environment variables
  environment_variables = [
    {
      name  = "NODE_ENV"
      value = "production"
    },
    {
      name  = "LOG_LEVEL"
      value = "info"
    }
  ]

  # Enable autoscaling for production
  enable_autoscaling         = true
  autoscaling_min_capacity   = 2
  autoscaling_max_capacity   = 10
  autoscaling_cpu_target     = 70
  autoscaling_memory_target  = 80

  # More conservative deployment settings
  max_capacity = 150  # Only 50% extra capacity during deployment
  min_capacity = 75   # Keep 75% healthy during deployment
}