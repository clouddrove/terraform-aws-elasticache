# Module      : Redis
# Description : Terraform module to create Elasticache Cluster and replica for Redis.
output "id" {
  value       = var.cluster_enabled ? "" : (var.cluster_replication_enabled ? join("", aws_elasticache_replication_group.cluster[*].id) : join("", aws_elasticache_replication_group.cluster[*].id))
  description = "Elasticache cluster id."
}

output "port" {
  value       = lookup(var.replication_group, "port", null)
  sensitive   = true
  description = "Redis port."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}

output "elasticache_endpoint" {
  value       = var.cluster_replication_enabled ? "" : (var.cluster_replication_enabled ? join("", aws_elasticache_replication_group.cluster[*].primary_endpoint_address) : join("", aws_elasticache_cluster.default[*].configuration_endpoint))
  description = "Elasticache endpoint address."
}

output "elasticache_arn" {
  value       = var.enable && length(aws_elasticache_replication_group.cluster) > 0 ? aws_elasticache_replication_group.cluster[0].arn : length(aws_elasticache_replication_group.cluster) > 0 ? aws_elasticache_replication_group.cluster[0].arn : null
  description = "Elasticache arn"
}

output "memcached_endpoint" {
  value       = var.enable && var.cluster_enabled ? join("", aws_elasticache_cluster.default[*].configuration_endpoint) : null
  description = "Memcached endpoint address."
}

output "memcached_arn" {
  value       = var.enable && length(aws_elasticache_cluster.default) > 0 ? aws_elasticache_cluster.default[0].arn : null
  description = "Memcached arn"
}

output "sg_id" {
  value = try(join("", aws_security_group.default[*].id), null)
}

output "hostname" {
  value       = try(join("", aws_route53_record.elasticache[*].fqdn), null)
  description = "DNS hostname"
}

output "memcached_hostname" {
  value       = try(join("", aws_route53_record.memcached_route_53[*].fqdn), null)
  description = "DNS hostname"
}

output "redis_ssm_name" {
  value       = try(join("", aws_ssm_parameter.secret-endpoint[*].name), null)
  description = "A list of all of the parameter values"
}

output "Memcached_ssm_name" {
  value       = try(join("", aws_ssm_parameter.memcached_secret-endpoint[*].name), null)
  description = "A list of all of the parameter values"
}

output "auth_token" {
  value       = var.enable && var.auth_token_enable && var.auto_generate_auth_token ? random_password.auth_token[0].result : null
  sensitive   = true
  description = "Auth token generated value"
}

### ---------- aws_elasticache_cluster ------------------------------
output "elasticache_engine_version_actual" {
  value       = try(aws_elasticache_cluster.default[0].engine_version_actual, null)
  description = "Running version of the cache engine"
}

output "elasticache_cache_nodes" {
  value       = try(aws_elasticache_cluster.default[0].cache_nodes, [])
  description = "List of node objects"
}

output "elasticache_cluster_address" {
  value       = try(aws_elasticache_cluster.default[0].cluster_address, null)
  description = "(Memcached only) DNS name of the cache cluster"
}

### ---------- aws_elasticache_replication_group --------------------

output "elasticache_engine_version" {
  description = "Running version of the cache engine."
  value       = try(aws_elasticache_replication_group.cluster[0].engine_version_actual, null)
}

output "elasticache_cluster_enabled" {
  description = "Indicates if cluster mode is enabled."
  value       = try(aws_elasticache_replication_group.cluster[0].cluster_enabled, null)
}

output "elasticache_configuration_endpoint_address" {
  description = "Address of the replication group configuration endpoint when cluster mode is enabled."
  value       = try(aws_elasticache_replication_group.cluster[0].configuration_endpoint_address, null)
}

output "elasticache_member_clusters" {
  description = "Identifiers of all the nodes that are part of this replication group."
  value       = try([for c in aws_elasticache_replication_group.cluster[0].member_clusters : c], null)
}

output "elasticache_reader_endpoint_address" {
  description = "Address of the endpoint for the reader node in the replication group, if cluster mode is disabled."
  value       = try(aws_elasticache_replication_group.cluster[0].reader_endpoint_address, null)
}

output "elasticache_tags_all" {
  description = "Map of tags assigned to the resource, including inherited ones."
  value       = try(aws_elasticache_replication_group.cluster[0].tags_all, null)
}
