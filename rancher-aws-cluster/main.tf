#Configure the Provider
provider "aws" {

  region = var.region
}

#Configure STATE FILE TO STORE ON S3
terraform {
  backend "s3" {
    bucket = "your aws bucket"
    key    = "your aws bucket/terraform.tfstate"
    region = "us-east-2"
  }
}

#VPC module [cofigures in all Regions, "makes" : cidr, internet ,nat gateway, public, private subnet]
module "vpc" {
  source             = "./module/vpc"
  vpc_cidr           = var.cidr
  vpc_network_name   = var.vpc_network_name
  ig_gateway_name    = var.ig_gateway_name
  nat_gateway_name   = var.nat_gateway_name
  env                = var.env_type
  public_subnets     = var.public_subnets_cidr
  private_subnets    = var.private_subnets_cidr
  availability_zones = data.aws_availability_zones.available.names
  domain_name        = var.domain_name
}

module "cluster" {
  depends_on = [
    module.vpc
  ]
  region                = var.region
  source                = "./module/cluster"
  instance_type         = var.instance_type
  public_subnet_id      = module.vpc.public_subnets
  private_subnet_id     = module.vpc.private_subnets
  ec2sg                 = module.vpc.bastion_sg
  availability_zones    = data.aws_availability_zones.available.names[0]
  keyname               = var.keyname
  rancher_instance_type = var.rancher_instance_type
  no_of_worker_nodes    = var.no_of_worker_nodes
  secret_manager_arn    = module.secrets-manager.secret_arns.secret-key
  privatekey            = module.cluster.privatekey
  vpc_id                = module.vpc.id
  target_group_name     = var.target_group_name
  load_balancer_name    = var.load_balancer_name
  domain_name           = var.domain_name
}

module "secrets-manager" {

  source = "lgallard/secrets-manager/aws"
  secrets = {
    secret-key = {
      description              = "private rsa for ec2"
      recovery_windows_in_days = 0
      secret_string            = module.cluster.tls_rsa_key
    },

  }

  tags = {
    Name        = "secrets_manager_for_private_key"
    Environment = var.env_type
  }
}
