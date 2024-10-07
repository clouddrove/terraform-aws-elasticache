# Module      : Redis
# Description : Terraform module to create Elasticache Cluster and replica for Redis.
output "id" {
  value       = var.cluster_enabled ? "" : (var.cluster_replication_enabled ? join("", aws_elasticache_replication_group.cluster[*].id) : join("", aws_elasticache_replication_group.cluster[*].id))
  description = "Redis cluster id."
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

output "redis_endpoint" {
  value       = var.cluster_replication_enabled ? "" : (var.cluster_replication_enabled ? join("", aws_elasticache_replication_group.cluster[*].primary_endpoint_address) : join("", aws_elasticache_cluster.default[*].configuration_endpoint))
  description = "Redis endpoint address."
}

output "redis_arn" {
  value       = var.enable && length(aws_elasticache_replication_group.cluster) > 0 ? aws_elasticache_replication_group.cluster[0].arn : length(aws_elasticache_replication_group.cluster) > 0 ? aws_elasticache_replication_group.cluster[0].arn : null
  description = "Redis arn"
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
  value       = var.enable && var.auth_token_enable ? random_password.auth_token[0].result : null
  sensitive   = true
  description = "Auth token generated value"
}
