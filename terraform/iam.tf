resource "aws_iam_role" "sentinel_task_execution_role" {
  name               = "sentinel-task-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "sentinel_task_execution_policy_attachment_ecr" {
  role       = aws_iam_role.sentinel_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "sentinel_task_execution_policy_attachment_cloudwatch" {
  role       = aws_iam_role.sentinel_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "sentinel_task_execution_policy_attachment_secrets" {
  role       = aws_iam_role.sentinel_task_execution_role.name
  policy_arn = aws_iam_policy.sentinel_secret_policy.arn
}
resource "aws_iam_role_policy_attachment" "sentinel_task_execution_policy_attachment_ssm" {
  role       = aws_iam_role.sentinel_task_role.name
  policy_arn = aws_iam_policy.sentinel_task_policy.arn
}

resource "aws_iam_policy" "sentinel_secret_policy" {
  name        = "sentinel-secret-policy"
  description = "IAM policy for Sentinel ECS secret"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "${aws_secretsmanager_secret.sentinel_secret.arn}"
            ]
        }
    ]
}
EOF
}
resource "aws_iam_policy" "sentinel_task_policy" {
  name        = "sentinel-task-policy"
  description = "IAM policy for Sentinel ECS task"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Action": [
              "ssmmessages:CreateControlChannel",
              "ssmmessages:CreateDataChannel",
              "ssmmessages:OpenControlChannel",
              "ssmmessages:OpenDataChannel"
        ],
        "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "sentinel_task_role" {
  name               = "sentinel-task-role"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}