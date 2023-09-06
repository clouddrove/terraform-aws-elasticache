# Module      : Redis
# Description : Terraform module to create Elasticache Cluster and replica for Redis.
output "id" {
  value       = var.cluster_enabled ? "" : (var.cluster_replication_enabled ? join("", aws_elasticache_replication_group.cluster[*].id) : join("", aws_elasticache_replication_group.cluster[*].id))
  description = "Redis cluster id."
}

output "port" {
  value       = var.port
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
  value       = length(aws_elasticache_replication_group.cluster) > 0 ? aws_elasticache_replication_group.cluster[0].arn : length(aws_elasticache_replication_group.cluster) > 0 ? aws_elasticache_replication_group.cluster[0].arn : ""
  description = "Redis arn"
}

output "memcached_endpoint" {
  value       = var.cluster_enabled ? join("", aws_elasticache_cluster.default[*].configuration_endpoint) : ""
  description = "Memcached endpoint address."
}

output "memcached_arn" {
  value       = length(aws_elasticache_cluster.default) > 0 ? aws_elasticache_cluster.default[0].arn : ""
  description = "Memcached arn"
}

output "sg_id" {
  value = join("", aws_security_group.default[*].id)
}

output "hostname" {
  value       = join("", aws_route53_record.elasticache[*].fqdn)
  description = "DNS hostname"
}

output "memcached_hostname" {
  value       = join("", aws_route53_record.memcached_route_53[*].fqdn)
  description = "DNS hostname"
}

output "redis_ssm_name" {
  value       = join("", aws_ssm_parameter.secret-endpoint[*].name)
  description = "A list of all of the parameter values"
}

output "Memcached_ssm_name" {
  value       = join("", aws_ssm_parameter.memcached_secret-endpoint[*].name)
  description = "A list of all of the parameter values"
}

output "auth_token" {
  value       = random_password.auth_token[0].result
  sensitive   = true
  description = "Auth token generated value"
}