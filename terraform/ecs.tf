resource "aws_ecs_cluster" "sentinel_cluster" {
  name = "sentinel-cluster"
}

resource "aws_ecr_repository" "sentinel_repository" {
  name = "sentinel"
}

resource "aws_cloudwatch_log_group" "sentinel_log_group" {
  name              = "/ecs/sentinel-service"
  retention_in_days = 30
}
resource "aws_secretsmanager_secret" "sentinel_secret" {
  name = "sentinel-secret"
}

resource "aws_secretsmanager_secret_version" "sentinel_secret" {
  secret_id = aws_secretsmanager_secret.sentinel_secret.id
  secret_string = jsonencode({
    "HTTP_RPC_NODE" : "HTTP_RPC_NODE",
    "PRIVATE_KEY" : "PRIVATE_KEY"
  })

  lifecycle {
    ignore_changes = [
      secret_string,
    ]
  }
}

resource "aws_ecs_task_definition" "sentinel_task" {
  family                   = "sentinel-task"
  execution_role_arn       = aws_iam_role.sentinel_task_execution_role.arn
  task_role_arn            = aws_iam_role.sentinel_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "512"
  memory = "1024"
  volume {
    name = "sentinel-efs"

    efs_volume_configuration {
      file_system_id          = "${aws_efs_file_system.sentinel_efs.id}"
      root_directory          = "data"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2049
      authorization_config {
        access_point_id = aws_efs_access_point.sentinel.id
        iam             = "ENABLED"
      }
    }
  }
  container_definitions = <<EOF
  [
    {
      "name": "sentinel-container",
      "image": "${aws_ecr_repository.sentinel_repository.repository_url}:latest",
      "secrets": [
        {
          "name": "HTTP_RPC_NODE",
          "valueFrom": "${aws_secretsmanager_secret.sentinel_secret.arn}:HTTP_RPC_NODE::"
        },
        {
          "name": "PRIVATE_KEY",
          "valueFrom": "${aws_secretsmanager_secret.sentinel_secret.arn}:PRIVATE_KEY::"
        }
      ],
      "environment": [
        { "name": "NODE_ENV", "value": "production" },
        { "name": "DB_PATH", "value": "data/db.sqlite" },
        { "name": "METRICS_PORT", "value": "9100" }
      ],
      "portMappings": [
        { "containerPort": 9100, "hostPort": 9100 }
      ],
      "mountPoints": [
        {
          "sourceVolume": "sentinel-efs",
          "containerPath": "/app/data"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.sentinel_log_group.name}",
          "awslogs-region": "eu-west-1",
          "awslogs-stream-prefix": "sentinel"
        }
      }
    }
  ]
  EOF
}

resource "aws_ecs_service" "sentinel_service" {
  name                   = "sentinel-service"
  cluster                = aws_ecs_cluster.sentinel_cluster.id
  task_definition        = aws_ecs_task_definition.sentinel_task.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    security_groups  = [aws_security_group.sentinel_sg.id]
    subnets          = [module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2]]
    assign_public_ip = true
  }
}

resource "aws_security_group" "sentinel_sg" {
  name        = "sentinel-security-group"
  description = "Security group for Sentinel service"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}