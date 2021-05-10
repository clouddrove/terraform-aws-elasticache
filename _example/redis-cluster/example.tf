provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "0.14.0"

  name        = "vpc"
  repository  = "https://registry.terraform.io/modules/clouddrove/vpc/aws/0.14.0"
  environment = "test"
  label_order = ["name", "environment"]

  cidr_block = "172.16.0.0/16"
}

module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "0.14.0"

  name               = "subnets"
  repository         = "https://registry.terraform.io/modules/clouddrove/subnet/aws/0.14.0"
  environment        = "test"
  label_order        = ["name", "environment"]
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  vpc_id             = module.vpc.vpc_id
  type               = "public"
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}

module "redis-sg" {
  source = "git::https://github.com/clouddrove/terraform-aws-security-group.git"

  name        = "redis-sg"
  repository  = "https://registry.terraform.io/modules/clouddrove/security-group/aws/0.14.0"
  environment = "test"
  label_order = ["name", "environment"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = [module.vpc.vpc_cidr_block]
  allowed_ports = [6379]
}

module "redis-cluster" {
  source = "./../../"

  name        = "cluster"
  repository  = "https://registry.terraform.io/modules/clouddrove/vpc/aws/0.14.0"
  environment = "test"
  label_order = ["name", "environment"]

  cluster_replication_enabled = true
  engine                      = "redis"
  engine_version              = "5.0.0"
  family                      = "redis5.0"
  port                        = 6379
  node_type                   = "cache.t2.micro"
  subnet_ids                  = module.subnets.public_subnet_id
  security_group_ids          = [module.redis-sg.security_group_ids]
  availability_zones          = ["eu-west-1a", "eu-west-1b"]
  auto_minor_version_upgrade  = true
  replicas_per_node_group     = 2
  num_node_groups             = 1
  automatic_failover_enabled  = true
}