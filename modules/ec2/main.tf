resource "aws_instance" "app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_type[terraform.workspace]
  subnet_id     = var.subnet_id

  tags = {
    IaC = true
  }
}