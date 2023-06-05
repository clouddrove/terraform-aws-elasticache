provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "1.3.1"

  name        = "vpc"
  environment = "test"
  label_order = ["name", "environment"]

  cidr_block = "172.16.0.0/16"
}

module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "1.3.0"

  name               = "subnets"
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
  source  = "clouddrove/security-group/aws"
  version = "1.3.0"

  name        = "redis-sg"
  environment = "test"
  label_order = ["name", "environment"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = [module.vpc.vpc_cidr_block]
  allowed_ports = [6379]
}

module "kms_key" {
  source  = "clouddrove/kms/aws"
  version = "1.3.0"

  name        = "kms"
  environment = "test"
  label_order = ["name", "environment"]

  enabled = true

  description              = "KMS key for aurora"
  alias                    = "alias/redis-cluster"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = 7
  is_enabled               = true
  policy                   = data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  version = "2012-10-17"

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

module "redis-cluster" {
  source = "./../../"

  name        = "cluster"
  environment = "test"
  label_order = ["name", "environment"]

  cluster_replication_enabled = true
  engine                      = "redis"
  engine_version              = "7.0"
  parameter_group_name        = "default.redis7.cluster.on"
  port                        = 6379
  node_type                   = "cache.t2.micro"
  kms_key_id                  = module.kms_key.key_arn
  subnet_ids                  = module.subnets.public_subnet_id
  security_group_ids          = [module.redis-sg.security_group_ids]
  availability_zones          = ["eu-west-1a", "eu-west-1b"]
  auto_minor_version_upgrade  = true
  replicas_per_node_group     = 2
  num_node_groups             = 1
  snapshot_retention_limit    = 7
  automatic_failover_enabled  = true
  extra_tags = {
    Application = "CloudDrove"
  }
}
