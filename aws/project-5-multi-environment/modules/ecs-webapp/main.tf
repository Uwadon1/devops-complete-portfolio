# Reusable ECS webapp module

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data sources
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.environment}-${var.app_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.environment}-${var.app_name}-logs"
    Environment = var.environment
    Project     = var.app_name
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.environment}-${var.app_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-${var.app_name}-execution-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-${var.app_name}-cluster"

  tags = {
    Name        = "${var.environment}-${var.app_name}-cluster"
    Environment = var.environment
    Project     = var.app_name
  }
}

# Security Group for the application
resource "aws_security_group" "app" {
  name        = "${var.environment}-${var.app_name}-sg"
  description = "Security group for ${var.environment} ${var.app_name}"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-${var.app_name}-sg"
    Environment = var.environment
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.environment}-${var.app_name}"
  network_mode            = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                     = var.cpu
  memory                  = var.memory
  execution_role_arn      = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = var.app_name
      image = var.container_image
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = concat(
        [
          {
            name  = "ENVIRONMENT"
            value = var.environment
          },
          {
            name  = "APP_NAME"
            value = var.app_name
          }
        ],
        var.environment_variables
      )
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      healthCheck = {
        command = [
          "CMD-SHELL",
          "curl -f http://localhost:${var.container_port}/health || exit 1"
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name        = "${var.environment}-${var.app_name}-task"
    Environment = var.environment
  }
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "${var.environment}-${var.app_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.app.id]
    assign_public_ip = true
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = {
    Name        = "${var.environment}-${var.app_name}-service"
    Environment = var.environment
  }
}

# Application Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  count              = var.enable_autoscaling ? 1 : 0
  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Application Auto Scaling Policy - CPU
resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  count              = var.enable_autoscaling ? 1 : 0
  name               = "${var.environment}-${var.app_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.autoscaling_cpu_target
  }
}

# Application Auto Scaling Policy - Memory
resource "aws_appautoscaling_policy" "ecs_memory_policy" {
  count              = var.enable_autoscaling ? 1 : 0
  name               = "${var.environment}-${var.app_name}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = var.autoscaling_memory_target
  }
}