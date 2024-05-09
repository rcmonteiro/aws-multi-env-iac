# Configuração de Infraestrutura Multi-Ambiente - AWS - IaC

Neste projeto será feita a configuração de uma infra com o terraform, 
com ambientes de `production`, `dev` e `staging`, cada um com suas respectivas 
`vpc`, `ec2` e `lb`, provisionados de acordo com as necessidades dos ambientes.

## Estrutura do projeto

```
modules
├── ec2
│   ├── datasources.tf
│   ├── main.tf
│   ├── variables.tf
├── vpc
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
├── lb
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
provider.tf
main.tf
```

### Diferentes ambientes
Antes de iniciar na declaração dos módulos do projeto, precisamos criar nossos 3 workspaces, e selecionar o ambiente dev
```sh
terraform workspace new dev
terraform workspace new staging
terraform workspace new production
terraform workspace select dev
```


### modules/vpc

As variáveis dos blocos de IPs, que vamos usar em cada ambiente, na VPC e nas duas subnets para rodar o Load Balance
```docker
# modules/vpc/variables.tf
variable "vpc_cidr_block" {
  description = "CIDR block para a VPC em seus respectivos ambientes"
  type        = map(string)
  default     = {
    dev        = "10.0.0.0/16"
    staging    = "10.0.0.0/16"
    production = "10.0.0.0/16"
  }
}

variable "vpc_cidr_block_a" {
  description = "CIDR block para a VPC em seus respectivos ambientes"
  type        = map(string)
  default     = {
    dev        = "10.0.0.0/17"
    staging    = "10.0.0.0/17"
    production = "10.0.0.0/17"
  }
}

variable "vpc_cidr_block_b" {
  description = "CIDR block para a VPC em seus respectivos ambientes"
  type        = map(string)
  default     = {
    dev        = "10.0.128.0/17"
    staging    = "10.0.128.0/17"
    production = "10.0.128.0/17"
  }
}
```

Criação da VPC, Subnets e Gateway para o Load Balance
```docker
# modules/vpc/main.tf
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block[terraform.workspace]
  tags = {
    IaC = true
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.vpc_cidr_block_a[terraform.workspace]
  availability_zone = "us-east-1a"
  tags = {
    IaC = true
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.vpc_cidr_block_b[terraform.workspace]
  availability_zone = "us-east-1b"
  tags = {
    IaC = true
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    IaC = true
  }
}
```

Export o subnet_id para ser usado depois na EC2 e LB
```docker
# modules/vpc/outputs.tf
output "subnet_a_id" {
  value = aws_subnet.subnet_a.id
  sensitive = false
  description = "Subnet A para o LB"
}

output "subnet_b_id" {
  value = aws_subnet.subnet_b.id
  sensitive = false
  description = "Subnet B para o LB"
}
```

Neste ponto podemos rodar os comandos:

```sh
terraform init # para instalar o módulo vpc
terraform fmt # para garantir o lint do nosso projeto
terraform validate # para garantir que os comandos estão corretos
terraform plan # para um dry run e ver o impacto das alterações
terraform apply -auto-approve # para aplicar as alterações
```

### modules/ec2
Agora vamos criar nossa EC2, primeiro, criando um lookup para buscar uma AMI de ubuntu atualizada
```docker
# modules/ec2/datasources.tf
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
```

Agora as variáveis para poder definir um tamanho de instância para cada ambiente
```docker
# modules/ec2/variables.tf
variable "ec2_type" {
  description = "Tamanho das EC2 por ambiente"
  type        = map(string)
  default     = {
    dev        = "t2.micro"
    staging    = "t2.micro"
    production = "t3.micro"
  }
}
```

Finalmente, criar o recurso propriamente dito, usando nossa vpc criada previamente

```docker
# modules/ec2/main.tf
resource "aws_instance" "app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_type[terraform.workspace]
  subnet_id     = var.subnet_id

  tags = {
    IaC = true
  }
}
```

Novamente, vamos rodar os comandos do terraform para conferir se tudo foi feito corretamente

```sh
terraform init # para instalar o módulo ec2
terraform fmt # para garantir o lint do nosso projeto
terraform validate # para garantir que os comandos estão corretos
terraform plan # para um dry run e ver o impacto das alterações
terraform apply -auto-approve # para aplicar as alterações
```

Finalmente vamos criar o load balance, declarando as variáveis que vamos usar

```docker
# modules/lb/variables.tf
variable "lb_name" {
  type        = string
  description = "Load Balance name"
}

variable "subnet_a_id" {
  type        = string
  description = "Subnet A ID"
}

variable "subnet_b_id" {
  type        = string
  description = "Subnet B ID"
}
```

E então criar o recurso, na mesma rede

```docker
# modules/lb/main.tf
resource "aws_lb" "lb" {
  name                = var.lb_name
  internal            = false
  load_balancer_type  = "application"

  subnet_mapping {
    subnet_id         = var.subnet_a_id
  }

  subnet_mapping {
    subnet_id         = var.subnet_b_id
  }

  tags = {
    IaC = true
  }
}
```

Agora, rodar os comandos para persistir na nuvem as alterações da infra

```sh
terraform init # para instalar o módulo lb
terraform fmt # para garantir o lint do nosso projeto
terraform validate # para garantir que os comandos estão corretos
terraform plan # para um dry run e ver o impacto das alterações
terraform apply -auto-approve # para aplicar as alterações
```