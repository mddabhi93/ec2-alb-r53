terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

module "networking" {
  source = "../../modules/networking"

  aws_region           = var.aws_region
  environment          = var.environment
  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security" {
  source = "../../modules/security"

  environment         = var.environment
  project_name        = var.project_name
  vpc_id              = module.networking.vpc_id
  allowed_cidr_blocks = var.allowed_cidr_blocks
}

module "iam" {
  source = "../../modules/iam"

  environment  = var.environment
  project_name = var.project_name
}

module "compute" {
  source = "../../modules/compute"

  environment           = var.environment
  project_name          = var.project_name
  instance_type         = var.instance_type
  private_subnet_id     = module.networking.private_subnet_ids[0]
  ec2_security_group_id = module.security.ec2_security_group_id
  instance_profile_name = module.iam.instance_profile_name
}

module "alb" {
  source = "../../modules/alb"

  environment           = var.environment
  project_name          = var.project_name
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  instance_id           = module.compute.instance_id
  acm_certificate_arn   = var.acm_certificate_arn
}

module "dns" {
  source = "../../modules/dns"

  create_route53_record = var.create_route53_record
  route53_zone_id       = var.route53_zone_id
  route53_record_name   = var.route53_record_name
  alb_dns_name          = module.alb.alb_dns_name
  alb_zone_id           = module.alb.alb_zone_id
}
