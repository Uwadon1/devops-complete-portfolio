# Development environment

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
      Environment = "dev"
      Project     = "multi-env-webapp"
      ManagedBy   = "terraform"
    }
  }
}

module "webapp" {
  source = "../../modules/ecs-webapp"

  environment     = "dev"
  app_name       = var.app_name
  aws_region     = var.aws_region
  container_image = var.container_image
  container_port = var.container_port

  # Development-specific settings
  cpu                = "256"     # Small resources for dev
  memory            = "512"
  desired_count     = 1          # Single instance
  log_retention_days = 7         # Short retention

  # Development environment variables
  environment_variables = [
    {
      name  = "DEBUG"
      value = "true"
    },
    {
      name  = "LOG_LEVEL"
      value = "debug"
    }
  ]

  # No autoscaling in dev
  enable_autoscaling = false
}