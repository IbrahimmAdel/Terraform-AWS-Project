provider "aws" {
  profile = var.profile
  region  = var.region
}

module "vpc" {
  source        = "./modules/vpc"
  vpc_cidr      = var.vpc_cidr
  nat_subnet_id = module.subnet.public_subnets_id[0]
}

module "subnet" {
  source       = "./modules/subnet"
  vpc_id       = module.vpc.vpc_id
  pub_subnets  = var.pub_subnet
  priv_subnets = var.priv_subnet
  igw_id       = module.vpc.igw_id
  nat_id       = module.vpc.nat_id
}

module "loadbalancer" {
  source         = "./modules/loadbalancer"
  lb_vpc_id      = module.vpc.vpc_id
  pub_target_id  = module.ec2.public_ec2_id
  priv_target_id = module.ec2.private_ec2_id
  lb_internal    = var.lb_internal
  lb_subnets     = [module.subnet.public_subnets_id,module.subnet.private_subnets_id]                   
  lb_sg_id       = module.ec2.security_group_id
}

module "ec2" {
  source                = "./modules/ec2"
  sg_vpc_id             = module.vpc.vpc_id
  priv_lb_dns           = module.loadbalancer.private_load_balancer_dns
  ec2_public_subnet_id  = module.subnet.public_subnets_id
  ec2_private_subnet_id = module.subnet.private_subnets_id
}

output "public_lb_ip" {
    value = module.loadbalancer.public_load_balancer_dns
}