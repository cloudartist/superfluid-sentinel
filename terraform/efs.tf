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

resource "aws_security_group" "sentinel_efs_sg" {
  name        = "sentinel-efs-sg"
  description = "Security group for Sentinel EFS"

  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "sentinel_efs_sg_ingress" {
  security_group_id       = aws_security_group.sentinel_efs_sg.id
  type                    = "ingress"
  from_port               = 2049
  to_port                 = 2049
  protocol                = "tcp"
  source_security_group_id = aws_security_group.sentinel_sg.id
}
