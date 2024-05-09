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