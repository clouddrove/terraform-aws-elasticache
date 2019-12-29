provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "git::https://github.com/clouddrove/terraform-aws-vpc.git?ref=tags/0.12.4"

  name        = "vpc"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

  cidr_block = "172.16.0.0/16"
}

module "subnets" {
  source = "git::https://github.com/clouddrove/terraform-aws-subnet.git?ref=tags/0.12.4"

  name        = "subnets"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  vpc_id             = module.vpc.vpc_id
  type               = "public"
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
}

module "memcached-sg" {
  source = "git::https://github.com/clouddrove/terraform-aws-security-group.git?ref=tags/0.12.3"

  name        = "ssh"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = [module.vpc.vpc_cidr_block]
  allowed_ports = [11211]
}

module "memcached" {
  source = "./../../"

  name        = "memcached"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

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
