####----------------------------------------------------------------------------------
## Provider block added, Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS.
####----------------------------------------------------------------------------------
provider "aws" {
  region = local.region
}
locals {
  name        = "redis"
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
  version = "2.0.0"

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
## Amazon ElastiCache [REDIS-CLUSTER] is a fully managed in-memory data store and cache service by Amazon Web Services.
## The service improves the performance of web applications by retrieving information from managed in-memory caches,
## instead of relying entirely on slower disk-based databases.
####----------------------------------------------------------------------------------
#tfsec:ignore:aws-cloudwatch-log-group-customer-key
module "redis" {
  source = "./../../"


  name        = local.name
  environment = local.environment
  ####----------------------------------------------------------------------------------
  ## Below A security group controls the traffic that is allowed to reach and leave the resources that it is associated with.
  ####----------------------------------------------------------------------------------
  vpc_id        = module.vpc.vpc_id
  allowed_ip    = [module.vpc.vpc_cidr_block]
  allowed_ports = [6379]

  cluster_replication_enabled = true
  engine                      = "redis"
  engine_version              = "7.0"
  parameter_group_name        = "default.redis7"
  port                        = 6379
  node_type                   = "cache.t2.micro"
  subnet_ids                  = module.subnets.public_subnet_id
  availability_zones          = [""]
  automatic_failover_enabled  = false
  multi_az_enabled            = false
  num_cache_clusters          = 1
  retention_in_days           = 0
  snapshot_retention_limit    = 7

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

  ####----------------------------------------------------------------------------------
  ## will create ROUTE-53 for redis which will add the dns of the cluster.
  ####----------------------------------------------------------------------------------
  route53_record_enabled         = true
  ssm_parameter_endpoint_enabled = true
  dns_record_name                = "prod"
  route53_ttl                    = "300"
  route53_type                   = "CNAME"
  route53_zone_id                = "Z017xxxxDLxxx0GH04"
}
