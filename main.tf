module "vpc" {
  source = "./modules/vpc"
}

module "ec2" {
  source      = "./modules/ec2"
  subnet_id   = module.vpc.subnet_a_id
  depends_on  = [module.vpc]
}

module "lb" {
  source      = "./modules/lb"
  subnet_a_id   = module.vpc.subnet_a_id
  subnet_b_id   = module.vpc.subnet_b_id
  lb_name     = "sample-lb-name-iac"
  depends_on  = [module.vpc]
}