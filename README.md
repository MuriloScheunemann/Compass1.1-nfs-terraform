# 1º Trabalho - Estágio AWS & DevSecOps - Compass UOL
Implementação do primeiro trabalho AWS/Linux- Estágio PB Compass Uol - com Terraform

# :clipboard: Índice:
- [Esquema do ambiente AWS](#esquema-do-ambiente-aws)
- [AWS com Terraform](#aws-com-terraform)
  + [main.tf](#maintf-heavy_check_mark)
  + [variables.tf](#variablestf-heavy_check_mark)
  + [terraform.tfvars](#terraformtfvars-heavy_check_mark)
  + [outputs.tf](#outputstf-heavy_check_mark)
  + [instance-keys-eip.tf](#instance-keys-eiptf-heavy_check_mark)
  + [efs.tf](#efstf-heavy_check_mark)
  + [secgp.tf](#secgptf-heavy_check_mark)
  + [vpc-sub-tbroutes.tf](#vpc-sub-tbroutestf-heavy_check_mark)
- [Gerando uma chave pública](#green_circle-gerando-uma-chave-pública)
# Esquema do ambiente AWS:
![esquema-1](https://github.com/MuriloScheunemann/Compass1.1-nfs-terraform/assets/122695407/687958aa-a8a0-4466-a400-961338ddcf9e)
# AWS com Terraform:
## main.tf :heavy_check_mark:
* Versão do Terraform
* Versão do provider AWS
* Parâmetros de configuração do provider AWS:
  * Região;
  * Perfil de acesso (.aws/credentials)
## variables.tf :heavy_check_mark:
Variáveis:
* aws_region:-------região AWS
* aws_profile:------perfil de acesso à AWS
* qtd_instancias:---quantidade de instâncias a serem criadas
* instance_ami:-----id da AMI que a(s) instância(s) terá(ão)
* instance_type:----tipo de instância
* chave_pub_file:---nome do arquivo da chave pública (localizado no mesmo diretório do root module)
## terraform.tfvars :heavy_check_mark:
Define valores para todas as variáveis. Esses valores podem ser alterados.
## outputs.tf :heavy_check_mark:
Saídas exibidas após a criação do ambiente:
* EFS_id: id do EFS (para montagem)
* chave-de-acesso: nome do key pair criado
* tipo-da-chave: tipo do key pair criado
* IPs-privados-instancias: IPs privados das instancias criadas
* IPs-publicos-instancias: IPs públicos das instâncias criadas (para acesso remoto SSH)
## instance-keys-eip.tf :heavy_check_mark:
Descreve os resources de criação das **chave de acesso, instâncias EC2 e Elastic IP**
### Chave de acesso:
* resource "aws_key_pair" "keypair"
  * cria uma chave de acesso, a partir de uma chave pública. (Ver: [Gerando uma chave pública](#green_circle-gerando-uma-chave-pública))
### Instância(s) EC2:
* resource "aws_instance" "instances":
  * cria uma quantidade (uma ou mais) de instâncias iguais (tipo, AMI, chave, SG, VPC, Subnet, AZ) definida na variável *qtd_instancias*, com um Elastic IP;
### Elastic IP:
* resource "aws_eip" "elastic-ips":
  * cria uma quantidade de Elastic IPs igual à quantidade de instâncias e os atribui às instâncias
## efs.tf :heavy_check_mark:
Descreve os resources de criação do **Elastic File System** e do **Mount Target**:
### EFS:
  * resource "aws_efs_file_system" "efs":
    * cria um EFS na mesma AZ da Subnet criada
### Mount Target:
  * resource "aws_efs_mount_target" "mountTargets":
    * cria um Mount Target para o EFS criado, na mesma subnet em que estão as instâncias:
## secgp.tf :heavy_check_mark:
Descreve os resources de criação dos **Security Groups**:
### Security Group (Mount Target):
  * resource "aws_security_group" "sg-efs":
    * cria um security group para o Mount Target. 
      * Entrada: aceita TCP/2049 e TCP/111 de origem no SG das instâncias.
      * Saída: todo tráfego.
    
|     Protocol   |   Port Range   |   Source           |
|     :---:      |        :---:   |        :---:       |
| TCP            | 2049           |    id: SG_INSTANCE |
| TCP            | 111            |   id: SG_INSTANCE  |

### Security Group (Instâncias):
  * resource "aws_security_group" "sg-instances"?
    * cria um security group para a(s) instância(s):
      * Entrada: aceita TCP/2049 e TCP/111 de origem no bloco CIDR da VPC, e TCP/22 de qualquer origem;
      * Saída: todo tráfego.
    
|     Protocol   |   Port Range   |   Source           |
|     :---:      |        :---:   |        :---:       |
| TCP            | 2049           |CIDR-block: vpc-efs |
| TCP            | 111            |CIDR-block: vpc-efs |
| TCP            | 22             |0.0.0.0/0           |
## vpc-sub-tbroutes.tf :heavy_check_mark:
Descreve os resources de criação da **VPC, Subnet, Internet Gateway, Route Table e associação da RT como main RT**:
### VPC:
  * resource "aws_vpc" "vpc-efs"
    * cria uma VPC com bloco CIDR 10.0.0.0/24 (256 hosts) e resolução de nomes ativada (para montagem do EFS)
### Subnet:
  * resource "aws_subnet" "subnet-efs"
    * cria uma sub-rede dentro da VPC criada, na AZ us-east-1a (poderia ser qualquer outra AZ dentro da região), com bloco CIDR 10.0.0.0/24 (utilizando toda faixa de IPs da VPC).
### Internet Gateway:
  * resource "aws_internet_gateway" "igw"
    * cria um internet gateway na VPC criada
### Route Table:
  * resource "aws_route_table" "routes"
    * cria uma tabela de roteamento na VPC, com rota de saída para qualquer IP (0.0.0.0/0), apontando para o IG.
### Associação da RT como main RT:
  * resource "aws_main_route_table_association" "RT_association"
    * cria uma associação da route table como main route table da VPC, permitindo conexão entre a subnet e o IG.

## :green_circle: Gerando uma chave pública:
Na seção de criação do recurso key pair, foi mencionado que é necessária uma chave pública para criar uma key pair na AWS. O tutorial a seguir mostra como gerá-la:
### Com Puttygen:
* Acesso SSH com máquina Windows, via Putty:
1. Abrir o Puttygen; selecionar tipo RSA, 2048 bits(outros valores funcionam também, mas este é o padrão);
2. Clicar em 'generate' para gerar uma nova chave;
3. Após a geração da chave, salvar a public key na mesma pasta do projeto Terraform e salvar a private key num local seguro na máquina local;
  + A chave pública será usada pelo Terraform para gerar uma nova key pair na AWS, enquanto a chave privada será usada para acessar as instâncias EC2 via SSH
### Com ssh-keygen:
* Acesso SSH com máquina Linux, via OpenSSH:
1. No terminal, executar: ssh-keygen -t rsa -b 2048;
2. Salvar as chaves criadas na máquina local (por padrão, serão salvas em .ssh, no diretório home do usuário que criou. Exemplo: usuário = murilo --> /home/murilo/.ssh/);
3. Copiar a chave pública id_rsa.pub para a mesma pasta do projeto Terraform

