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
module "secrets_manager" {
  source  = "clouddrove/secrets-manager/aws"
  version = "2.0.0"

  name        = local.name
  environment = local.environment

  unmanaged = true
  secrets = [
    {
      name                    = "aws/elasticache/auth-tokens"
      description             = "Elasticache AUTH Token"
      recovery_window_in_days = 7
      secret_string           = "{ \"auth_token\": \"UseSomethingSecure*1234\"}"
    }
  ]
}

data "aws_secretsmanager_secret" "auth_token" {
  depends_on = [module.secrets_manager]
  name       = "aws/elasticache/auth-tokens"
}

data "aws_secretsmanager_secret_version" "auth_token" {
  secret_id = data.aws_secretsmanager_secret.auth_token.id
}

##----------------------------------------------------------------------------------
## VALKEY MODULE CALL
##----------------------------------------------------------------------------------
module "valkey" {
  source = "./../../"

  name        = local.name
  environment = local.environment

  vpc_id                   = module.vpc.vpc_id
  allowed_ip               = [module.vpc.vpc_cidr_block]
  allowed_ports            = [6379]
  subnet_ids               = concat(module.subnets.private_subnet_id, module.subnets.public_subnet_id)
  subnet_group_description = "${local.environment}-${local.name} subnet group."
  availability_zones       = ["${local.region}a", "${local.region}c"]

  cluster_replication_enabled = true
  replication_group = {
    engine                        = "valkey"
    engine_version                = "8.1"
    parameter_group_name          = "default.valkey8"
    port                          = 6379
    num_cache_clusters            = 2
    apply_immediately             = true
    node_type                     = "cache.t3.micro"
    replication_group_description = "${local.environment}-${local.name} replication group."
    maintenance_window            = "sat:03:30-sat:04:30"
  }
  az_mode                    = "single-az"
  kms_key_id                 = null # -- AWS Owned KMS Key
  auth_token                 = jsondecode(data.aws_secretsmanager_secret_version.auth_token.secret_string)["auth_token"]
  auth_token_update_strategy = "SET"
  sg_ids                     = [module.vpc.vpc_default_security_group_id]

}
