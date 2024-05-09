variable "ec2_type" {
  description = "Tamanho das EC2 por ambiente"
  type        = map(string)
  default     = {
    dev        = "t2.micro"
    staging    = "t2.micro"
    production = "t3.micro"
  }
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID"
}