####----------------------------------------------------------------------------------
## Provider block added, Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS.
####----------------------------------------------------------------------------------
provider "aws" {
  region = local.region
}
locals {
  name        = "memcached"
  environment = "test"
  region      = "eu-west-1"
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
  version = "2.0.1"

  name               = "${local.name}-subnets"
  environment        = local.environment
  availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  vpc_id             = module.vpc.vpc_id
  type               = "public"
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}

####----------------------------------------------------------------------------------
## Memcached holds its data in memory.
####----------------------------------------------------------------------------------
module "memcached" {
  source = "./../../"

  name        = local.name
  environment = local.environment
  ####----------------------------------------------------------------------------------
  ## Below A security group controls the traffic that is allowed to reach and leave the resources that it is associated with.
  ####----------------------------------------------------------------------------------
  vpc_id        = module.vpc.vpc_id
  allowed_ip    = [module.vpc.vpc_cidr_block]
  allowed_ports = [11211]

  cluster_enabled                          = true
  memcached_ssm_parameter_endpoint_enabled = true
  memcached_route53_record_enabled         = false

  replication_group = {
    engine               = "memcached"
    engine_version       = "1.6.17"
    parameter_group_name = ""
    port                 = 11211
    node_type            = "cache.t2.micro"
    parameter_group_name = ""
  }

  az_mode            = "cross-az"
  num_cache_nodes    = 2
  subnet_ids         = module.subnets.public_subnet_id
  availability_zones = ["eu-west-1a", "eu-west-1b"]
  extra_tags = {
    Application = "CloudDrove"
  }

  ####----------------------------------------------------------------------------------
  ## will create ROUTE-53 for redis which will add the dns of the cluster.
  ####----------------------------------------------------------------------------------
  route53_record_enabled         = false
  ssm_parameter_endpoint_enabled = false
  route53 = {
    dns_record_name = "prod"
    route53_ttl     = "300"
    route53_type    = "CNAME"
    route53_zone_id = "SERFxxxx6XCsY9Lxxxxx" # Change Zone ID with Route53 Zone ID from looking at AWS Console
  }
}
