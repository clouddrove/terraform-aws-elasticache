provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "git::https://github.com/clouddrove/terraform-aws-vpc.git?ref=tags/0.12.1"

  name        = "vpc"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]

  cidr_block = "10.0.0.0/16"
}

module "subnets" {
  source = "git::https://github.com/clouddrove/terraform-aws-subnet.git?ref=tags/0.12.1"

  name        = "subnets"
  application = "clouddrove"
  environment = "test"
  label_order = ["application", "environment", "name"]

  availability_zones = ["us-east-1a", "us-east-1b"]
  vpc_id             = module.vpc.vpc_id
  type               = "public"
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
}

module "redis-sg" {
  source = "git::https://github.com/clouddrove/terraform-aws-security-group.git?ref=tags/0.12.1"

  name        = "ssh"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = [module.vpc.vpc_cidr_block]
  allowed_ports = [6379]
}

module "redis-cluster" {
  source = "git::https://github.com/clouddrove/terraform-aws-elasticache?ref=tags/0.12.0"

  name        = "cluster"
  application = "cd"
  environment = "test"
  label_order = ["environment", "name", "application"]

  cluster_replication_enabled = true
  engine                      = "redis"
  engine_version              = "5.0.0"
  family                      = "redis5.0"
  port                        = 6379
  node_type                   = "cache.t2.micro"
  subnet_ids                  = module.subnets.public_subnet_id
  security_group_ids          = [module.redis-sg.security_group_ids]
  availability_zones          = ["us-east-1a", "us-east-1b"]
  auto_minor_version_upgrade  = true
  replicas_per_node_group     = 2
  num_node_groups             = 1
  automatic_failover_enabled  = true
}


