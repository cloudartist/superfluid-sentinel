resource "aws_efs_file_system" "sentinel_efs" {
  creation_token = "sentinel-efs"
}

resource "aws_efs_mount_target" "sentinel_efs_mount_target" {
  file_system_id = aws_efs_file_system.sentinel_efs.id
  subnet_id      = module.vpc.public_subnets[0]
  security_groups = [
    aws_security_group.sentinel_efs_sg.id,
  ]
}
resource "aws_efs_mount_target" "sentinel_efs_mount_target_1" {
  file_system_id = aws_efs_file_system.sentinel_efs.id
  subnet_id      = module.vpc.public_subnets[1]
  security_groups = [
    aws_security_group.sentinel_efs_sg.id,
  ]
}
resource "aws_efs_mount_target" "sentinel_efs_mount_target_2" {
  file_system_id = aws_efs_file_system.sentinel_efs.id
  subnet_id      = module.vpc.public_subnets[2]
  security_groups = [
    aws_security_group.sentinel_efs_sg.id,
  ]
}

resource "aws_efs_access_point" "sentinel" {
  file_system_id = aws_efs_file_system.sentinel_efs.id
  posix_user {
    gid = 1000
    uid = 1000
  }
  root_directory {
    path = "/data"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 777
    }
  }
}

resource "aws_security_group" "sentinel_efs_sg" {
  name        = "sentinel-efs-sg"
  description = "Security group for Sentinel EFS"

  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "sentinel_efs_sg_ingress" {
  security_group_id        = aws_security_group.sentinel_efs_sg.id
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sentinel_sg.id
}
# resource "aws_security_group_rule" "sentinel_efs_sg_egress" {
#   security_group_id        = aws_security_group.sentinel_efs_sg.id
#   type                     = "egress"
#   from_port                = 2049
#   to_port                  = 2049
#   protocol                 = "tcp"
#   source_security_group_id = aws_security_group.sentinel_sg.id
# }

resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.sentinel_efs.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "ExamplePolicy01",
    "Statement": [
        {
            "Sid": "ExampleSatement01",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.sentinel_efs.arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                }
            }
        }
    ]
}
POLICY

}