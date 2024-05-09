terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.48.0"
    }
  }
}

provider "aws" {
  profile = "rcmonteiro-iac"
  region  = "us-east-1"
}