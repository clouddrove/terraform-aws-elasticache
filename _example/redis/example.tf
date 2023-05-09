provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "1.3.0"

  name        = "vpc"
  environment = "test"
  label_order = ["name", "environment"]
  cidr_block  = "172.16.0.0/16"
}

module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "1.3.0"

  name        = "subnets"
  environment = "test"
  label_order = ["name", "environment"]

  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  vpc_id             = module.vpc.vpc_id
  type               = "public"
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}

module "redis-sg" {
  source  = "clouddrove/security-group/aws"
  version = "1.3.0"

  name        = "redis-sg"
  environment = "test"
  label_order = ["name", "environment"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = [module.vpc.vpc_cidr_block]
  allowed_ports = [6379]
}

module "redis" {
  source      = "./../../"
  name        = "redis"
  environment = "test"
  label_order = ["name", "environment"]

  replication_enabled        = true
  engine                     = "redis"
  engine_version             = "6.2"
  parameter_group_name       = "default.redis6.x"
  port                       = 6379
  node_type                  = "cache.t2.micro"
  subnet_ids                 = module.subnets.public_subnet_id
  security_group_ids         = [module.redis-sg.security_group_ids]
  availability_zones         = ["eu-west-1a", "eu-west-1b"]
  auto_minor_version_upgrade = true
  num_cache_clusters         = 2
  retention_in_days          = 0
  snapshot_retention_limit   = 7

  log_delivery_configuration = [
    {
      destination_type = "cloudwatch-logs"
      log_format       = "json"
      log_type         = "slow-log"
    },
    {
      destination_type = "cloudwatch-logs"
      log_format       = "json"
      log_type         = "engine-log"
    }
  ]
  extra_tags = {
    Application = "CloudDrove"
  }
}
