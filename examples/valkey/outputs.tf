### ---------- aws_elasticache_replication_group --------------------
output "valkey_elasticache_arn" {
  description = "ARN of the created ElastiCache Replication Group."
  value       = module.valkey.elasticache_arn
}

output "valkey_elasticache_engine_version" {
  description = "Running version of the cache engine."
  value       = module.valkey.elasticache_engine_version
}

output "valkey_elasticache_cluster_enabled" {
  description = "Indicates if cluster mode is enabled."
  value       = module.valkey.elasticache_cluster_enabled
}

output "valkey_elasticache_configuration_endpoint_address" {
  description = "Address of the replication group configuration endpoint when cluster mode is enabled."
  value       = module.valkey.elasticache_configuration_endpoint_address
}

output "valkey_elasticache_id" {
  description = "ID of the ElastiCache Replication Group."
  value       = module.valkey.id
}

output "valkey_elasticache_member_clusters" {
  description = "Identifiers of all the nodes that are part of this replication group."
  value       = module.valkey.elasticache_member_clusters
}

output "valkey_elasticache_primary_endpoint_address" {
  description = "Address of the endpoint for the primary node in the replication group, if cluster mode is disabled."
  value       = module.valkey.elasticache_endpoint
}

output "valkey_elasticache_reader_endpoint_address" {
  description = "Address of the endpoint for the reader node in the replication group, if cluster mode is disabled."
  value       = module.valkey.elasticache_reader_endpoint_address
}

output "valkey_elasticache_tags_all" {
  description = "Map of tags assigned to the resource, including inherited ones."
  value       = module.valkey.elasticache_tags_all
}
