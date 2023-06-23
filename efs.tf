# EFS
resource "aws_efs_file_system" "efs" {
  availability_zone_name = aws_subnet.subnet-efs.availability_zone #EFS na mesma AZ da subnet criada
  tags = {
    Name = "MeuEFS"
  }
}
#Mount Target
resource "aws_efs_mount_target" "mountTargets" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.subnet-efs.id
  security_groups = [aws_security_group.sg-efs.id]
}
