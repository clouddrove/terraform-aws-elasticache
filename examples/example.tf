provider "aws" {
  profile                 = "default"
  region                  = "us-east-1"
}


module "redis" {
  source = "git::https://github.com/clouddrove/terraform-aws-elasticache-redis.git"
  organization                               = "clouddrove"
  environment                                = "stage"
  name                                       = "backend"
  engine                                     = "redis"
  engine_version                             = "5.0.0"
  family                                     = "redis5.0"
  port                                       = 6379
  node_type                                  = "cache.t2.micro"
  subnet_ids                                 = ["subnet-423fbd27" , "subnet-18d8ad35" ]
  security_group_ids                         = ["sg-042b5876d6decaae0"]
  availability_zones                         =   ["us-east-1a","us-east-1b" ]
  auto_minor_version_upgrade                 = true
  number_cache_clusters                      =   2
}
