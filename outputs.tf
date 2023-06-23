# ID do EFS que será usado no user data para monta-lo nas instancias
output "EFS-id" {
  value = aws_efs_file_system.efs.id
}

# Nome e tipo da Chave que será usada para fazer acesso SSH
output "chave-de-acesso" {
  value = aws_key_pair.keypair.key_name
}

output "tipo-da-chave" {
  value = aws_key_pair.keypair.key_type
}

# IPs publicos e privados das instancias
output "IPs-privados-instancias" {
  value = aws_instance.instances[*].private_ip
}

output "IPs-publicos-instancias" {
  value = aws_eip.elastic-ips[*].public_ip
}
