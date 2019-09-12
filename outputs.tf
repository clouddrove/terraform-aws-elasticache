# Module      : Redis
# Description : Terraform module to create Elasticache Cluster and replica for Redis.
output "id" {
  value = var.cluster_enabled ? "" : concat(
    aws_elasticache_replication_group.default.*.id,
    aws_elasticache_replication_group.cluster.*.id
  )[0]
  description = "Redis cluster id."
}

//output "cache_nodes" {
//value       = var.cluster_enabled ? "" : aws_elasticache_replication_group.default.*.cache_nodes
//description = "Redis cluster id."
//}

output "port" {
  value       = var.port
  description = "Redis port."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}