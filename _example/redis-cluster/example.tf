provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "0.15.1"

  name        = "vpc"
  environment = "staging"
  label_order = ["name", "environment"]

  cidr_block = "10.30.0.0/16"
}

module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "0.15.3"

  name               = "subnets"
  environment        = "staging"
  label_order        = ["name", "environment"]
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_id             = vpc-0ee19486fa69d866e
  type               = "public"
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}

module "redis-sg" {
  source  = "clouddrove/security-group/aws"
  version = "1.0.1"

  name        = "redis-sg"
  environment = "staging"
  label_order = ["name", "environment"]

  vpc_id        = vpc-0ee19486fa69d866e
  allowed_ip    = ["10.30.0.0/16"]
  allowed_ports = [6379]
}

module "redis-cluster" {
  source = "./../../"

  name        = "cluster"
  environment = "staging"
  label_order = ["name", "environment"]

  cluster_replication_enabled = true
  engine                      = "redis"
  engine_version              = "6.x"
  parameter_group_name        = "default.redis6.x.cluster.on"
  port                        = 6379
  node_type                   = "cache.t2.micro"
  subnet_ids                  = module.subnets.public_subnet_id
  security_group_ids          = [module.redis-sg.security_group_ids]
  availability_zones          = ["us-east-1a", "us-east-1b"]
  auto_minor_version_upgrade  = true
  replicas_per_node_group     = 2
  num_node_groups             = 1
  automatic_failover_enabled  = true
  extra_tags = {
    Application = "CloudDrove"
  }
}
