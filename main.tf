## Managed By : CloudDrove
# Description : This Script is used to create Elasticache Cluster and replica for Redis and
#               Memcache.
## Copyright @ CloudDrove. All Right Reserved.

#Module      : label
#Description : This terraform module is designed to generate consistent label names and
#              tags for resources. You can use terraform-labels to implement a strict
#              naming convention.
module "labels" {
  source = "git::https://github.com/clouddrove/terraform-labels.git?ref=tags/0.12.0"

  name        = var.name
  application = var.application
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
}

# Module      : Elasticache Subnet Group
# Description : Terraform module which creates Subnet Group for Elasticache.
resource "aws_elasticache_subnet_group" "default" {
  count       = var.enable ? 1 : 0
  name        = module.labels.id
  subnet_ids  = var.subnet_ids
  description = "Managed by ${var.managedby}"
}

# Module      : Elasticache Replication Group
# Description : Terraform module which creates standalone instance for Elasticache Redis.
resource "aws_elasticache_replication_group" "default" {
  count                         = var.enable && var.replication_enabled ? 1 : 0
  engine                        = var.engine
  replication_group_id          = module.labels.id
  replication_group_description = module.labels.id
  engine_version                = var.engine_version
  port                          = var.port
  parameter_group_name          = "default.redis5.0"
  node_type                     = var.node_type
  automatic_failover_enabled    = var.automatic_failover_enabled
  subnet_group_name             = join("", aws_elasticache_subnet_group.default.*.name)
  security_group_ids            = var.security_group_ids
  security_group_names          = var.security_group_names
  snapshot_arns                 = var.snapshot_arns
  snapshot_name                 = var.snapshot_name
  notification_topic_arn        = var.notification_topic_arn
  snapshot_window               = var.snapshot_window
  snapshot_retention_limit      = var.snapshot_retention_limit
  apply_immediately             = var.apply_immediately
  availability_zones            = slice(var.availability_zones, 0, var.number_cache_clusters)
  number_cache_clusters         = var.number_cache_clusters
  auto_minor_version_upgrade    = var.auto_minor_version_upgrade
  maintenance_window            = var.maintenance_window
  at_rest_encryption_enabled    = var.at_rest_encryption_enabled
  transit_encryption_enabled    = var.transit_encryption_enabled
  auth_token                    = var.auth_token
  tags                          = module.labels.tags
}

# Module      : Elasticache Replication Group
# Description : Terraform module which creates cluster for Elasticache Redis.
resource "aws_elasticache_replication_group" "cluster" {
  count                         = var.enable && var.cluster_replication_enabled ? 1 : 0
  engine                        = var.engine
  replication_group_id          = module.labels.id
  replication_group_description = module.labels.id
  engine_version                = var.engine_version
  port                          = var.port
  parameter_group_name          = "default.redis5.0.cluster.on"
  node_type                     = var.node_type
  automatic_failover_enabled    = var.automatic_failover_enabled
  subnet_group_name             = join("", aws_elasticache_subnet_group.default.*.name)
  security_group_ids            = var.security_group_ids
  security_group_names          = var.security_group_names
  snapshot_arns                 = var.snapshot_arns
  snapshot_name                 = var.snapshot_name
  notification_topic_arn        = var.notification_topic_arn
  snapshot_window               = var.snapshot_window
  snapshot_retention_limit      = var.snapshot_retention_limit
  apply_immediately             = var.apply_immediately
  availability_zones            = slice(var.availability_zones, 0, var.num_node_groups)
  auto_minor_version_upgrade    = var.auto_minor_version_upgrade
  maintenance_window            = var.maintenance_window
  at_rest_encryption_enabled    = var.at_rest_encryption_enabled
  transit_encryption_enabled    = var.transit_encryption_enabled
  auth_token                    = var.auth_token
  tags                          = module.labels.tags
  cluster_mode {
    replicas_per_node_group = var.replicas_per_node_group #Replicas per Shard
    num_node_groups         = var.num_node_groups         #Number of Shards
  }
}

# Module      : Elasticache Cluster
# Description : Terraform module which creates cluster for Elasticache Memcached.
resource "aws_elasticache_cluster" "default" {
  count                        = var.enable && var.cluster_enabled ? 1 : 0
  engine                       = var.engine
  cluster_id                   = module.labels.id
  engine_version               = var.engine_version
  port                         = var.port
  num_cache_nodes              = var.num_cache_nodes
  az_mode                      = var.az_mode
  parameter_group_name         = "default.memcached1.5"
  node_type                    = var.node_type
  subnet_group_name            = join("", aws_elasticache_subnet_group.default.*.name)
  security_group_ids           = var.security_group_ids
  security_group_names         = var.security_group_names
  snapshot_arns                = var.snapshot_arns
  snapshot_name                = var.snapshot_name
  notification_topic_arn       = var.notification_topic_arn
  snapshot_window              = var.snapshot_window
  snapshot_retention_limit     = var.snapshot_retention_limit
  apply_immediately            = var.apply_immediately
  preferred_availability_zones = slice(var.availability_zones, 0, var.num_cache_nodes)
  maintenance_window           = var.maintenance_window
  tags                         = module.labels.tags
}
