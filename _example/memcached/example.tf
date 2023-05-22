provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "1.3.0"

  name        = "vpc"
  environment = "test"
  label_order = [
  "name", "environment"]

  cidr_block = "172.16.0.0/16"
}

module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "1.3.0"

  name        = "subnets"
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
  version = "1.3.0"

  name        = "memcached-sg"
  environment = "test"
  label_order = ["name", "environment"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = [module.vpc.vpc_cidr_block]
  allowed_ports = [11211]
}

module "kms_key" {
  source  = "clouddrove/kms/aws"
  version = "1.3.0"

  name        = "kms"
  environment = "test"
  label_order = ["name", "environment"]

  enabled                  = true
  description              = "KMS key for aurora"
  alias                    = "alias/aurora"
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

module "memcached" {
  source = "./../../"

  name        = "memcached"
  environment = "test"
  label_order = ["name", "environment"]

  cluster_enabled      = true
  engine               = "memcached"
  engine_version       = "1.5.10"
  family               = "memcached1.5"
  parameter_group_name = ""
  az_mode              = "cross-az"
  port                 = 11211
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 2
  kms_key_id           = module.kms_key.key_arn
  subnet_ids           = module.subnets.public_subnet_id
  security_group_ids   = [module.memcached-sg.security_group_ids]
  availability_zones   = ["eu-west-1a", "eu-west-1b"]
  extra_tags = {
    Application = "CloudDrove"
  }
}