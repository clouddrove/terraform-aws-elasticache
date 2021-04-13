provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source      = "clouddrove/vpc/aws"
  version     = "0.14.0"
  name        = "vpc"
  environment = "test"
  label_order = ["environment", "name"]

  cidr_block = "172.16.0.0/16"
}

module "subnets" {
  source      = "clouddrove/subnet/aws"
  version     = "0.14.0"
  name        = "subnets"
  environment = "test"
  label_order = ["environment", "name"]
  repository  = "https://registry.terraform.io/modules/clouddrove/subnet/aws/"

  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  vpc_id             = module.vpc.vpc_id
  type               = "public"
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}

module "redis-sg" {
  source      = "git::https://github.com/clouddrove/terraform-aws-security-group.git?ref=tags/0.14.0"
  name        = "ssh"
  environment = "test"
  label_order = ["environment", "name"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = [module.vpc.vpc_cidr_block]
  allowed_ports = [6379]
}

module "redis" {
  source      = "./../../"
  name        = "redis"
  environment = "test"
  label_order = ["environment", "name"]

  replication_enabled        = true
  engine                     = "redis"
  engine_version             = "5.0.0"
  family                     = "redis5.0"
  port                       = 6379
  node_type                  = "cache.t2.micro"
  subnet_ids                 = module.subnets.public_subnet_id
  security_group_ids         = [module.redis-sg.security_group_ids]
  availability_zones         = ["eu-west-1a", "eu-west-1b"]
  auto_minor_version_upgrade = true
  number_cache_clusters      = 2
}
