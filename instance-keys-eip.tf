resource "aws_key_pair" "keypair" {
  key_name   = "chaveSSH"
  public_key = file("./${var.chave_pub_file}")
}

resource "aws_instance" "instances" {

  count = var.qtd_instancias <= 0 ? 0 : var.qtd_instancias

  ami           = var.instance_ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.keypair.key_name

  security_groups   = [aws_security_group.sg-instances.id]
  availability_zone = aws_subnet.subnet-efs.availability_zone
  subnet_id         = aws_subnet.subnet-efs.id
  # associate_public_ip_address = true

  tags = {
    "Name" = "instancia-${count.index + 1}"
  }
}

resource "aws_eip" "elastic-ips" {
  count = var.qtd_instancias <= 0 ? 0 : var.qtd_instancias

  instance = aws_instance.instances[count.index].id

  tags = {
    "Name" = "Elastic-IP-${count.index + 1}"
  }
}

