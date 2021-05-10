provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "0.14.0"

  name        = "vpc"
  repository  = "https://registry.terraform.io/modules/clouddrove/vpc/aws/0.14.0"
  environment = "test"
  label_order = [
  "name", "environment"]

  cidr_block = "172.16.0.0/16"
}

module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "0.14.0"

  name        = "subnets"
  repository  = "https://registry.terraform.io/modules/clouddrove/subnet/aws/0.14.0"
  environment = "test"
  label_order = ["name", "environment"]

  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  vpc_id             = module.vpc.vpc_id
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
  type               = "public"
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
}

module "memcached-sg" {
  source  = "clouddrove/security-group/aws"
  version = "0.14.0"

  name        = "memcached-sg"
  repository  = "https://registry.terraform.io/modules/clouddrove/security-group/aws/0.14.0"
  environment = "test"
  label_order = ["name", "environment"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = [module.vpc.vpc_cidr_block]
  allowed_ports = [11211]
}

module "memcached" {
  source = "./../../"

  name        = "memcached"
  environment = "test"
  label_order = ["name", "environment"]

  cluster_enabled    = true
  engine             = "memcached"
  engine_version     = "1.5.10"
  family             = "memcached1.5"
  az_mode            = "cross-az"
  port               = 11211
  node_type          = "cache.t2.micro"
  num_cache_nodes    = 2
  subnet_ids         = module.subnets.public_subnet_id
  security_group_ids = [module.memcached-sg.security_group_ids]
  availability_zones = ["eu-west-1a", "eu-west-1b"]
}
