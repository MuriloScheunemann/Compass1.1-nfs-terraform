# SG para o Mount Target
resource "aws_security_group" "sg-efs" {
  name        = "SG-EFS"
  description = "allow-TCP-2049"
  vpc_id      = aws_vpc.vpc-efs.id

  ingress {
    description     = "NFS"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-instances.id]
  }

  ingress {
    description     = "NFS"
    from_port       = 111
    to_port         = 111
    protocol        = "tcp"
    security_groups = [aws_security_group.sg-instances.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SecGp-EFS"
  }
}

# SG para as instancias
resource "aws_security_group" "sg-instances" {
  name        = "SG-INSTANCE"
  description = "allow-TCP-2049-22"
  vpc_id      = aws_vpc.vpc-efs.id

  ingress {
    description = "NFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc-efs.cidr_block]
  }

  ingress {
    description = "NFS"
    from_port   = 111
    to_port     = 111
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc-efs.cidr_block]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SecGp-EFS"
  }
}