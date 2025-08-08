####----------------------------------------------------------------------------------
## Provider block added, Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS.
####----------------------------------------------------------------------------------
provider "aws" {
  region = local.region
}
locals {
  name        = "valkey"
  environment = "test"
  region      = "us-east-1"
}
####----------------------------------------------------------------------------------
## A VPC is a virtual network that closely resembles a traditional network that you'd operate in your own data center.
####----------------------------------------------------------------------------------
module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "2.0.0"

  name        = "${local.name}-vpc"
  environment = local.environment
  cidr_block  = "10.0.0.0/16"
}

####----------------------------------------------------------------------------------
## A subnet is a range of IP addresses in your VPC.
####----------------------------------------------------------------------------------
module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "2.0.0"

  name               = "${local.name}-subnets"
  environment        = local.environment
  availability_zones = ["${local.region}a", "${local.region}b", "${local.region}c"]
  vpc_id             = module.vpc.vpc_id
  type               = "public"
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}

##----------------------------------------------------------------------------------
## VALKEY MODULE CALL
##----------------------------------------------------------------------------------
module "valkey" {
  source = "./../../"

  name        = local.name
  environment = local.environment

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = [module.vpc.vpc_cidr_block]
  allowed_ports = [6379]

  # -- valkey configuration
  cluster_replication_enabled = true
  replication_group = {
    engine                        = "valkey"
    engine_version                = "8.1"
    parameter_group_name          = "default.valkey8"
    port                          = 6379
    num_cache_clusters            = 2
    node_type                     = "cache.t3.medium"
    replication_group_description = "${local.environment}-${local.name} replication group."
    maintenance_window            = "tue:07:00-tue:08:00"
  }

  az_mode         = "single-az"
  num_cache_nodes = 2
  kms_key_id      = null
  auth_token      = "UseSomethingSecure*1234"
  # ---- valkey end -----------------
  subnet_ids               = concat(module.subnets.private_subnet_id, module.subnets.public_subnet_id)
  subnet_group_description = "${local.environment}-${local.name} subnet group."
  availability_zones       = ["${local.region}a", "${local.region}c"]
}