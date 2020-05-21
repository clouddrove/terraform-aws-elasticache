# Module      : Redis
# Description : Terraform module to create Elasticache Cluster and replica for Redis.
output "id" {
  value       = var.cluster_enabled ? "" : (var.replication_enabled ? join("", aws_elasticache_replication_group.default.*.id) : join("", aws_elasticache_replication_group.cluster.*.id))
  description = "Redis cluster id."
}

output "port" {
  value       = var.port
  description = "Redis port."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}
  
output "endpoint" {
  value       = var.cluster_enabled ? join("", aws_elasticache_replication_group.cluster.*.configuration_endpoint_address) : join("", aws_elasticache_replication_group.default.*.primary_endpoint_address)
  description = "Redis primary endpoint."
}
