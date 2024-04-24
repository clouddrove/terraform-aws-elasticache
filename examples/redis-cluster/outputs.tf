output "id" {
  value       = module.redis-cluster.id
  description = "Redis cluster id."
}

output "tags" {
  value       = module.redis-cluster.tags
  description = "A mapping of tags to assign to the resource."
}

output "redis_endpoint" {
  value       = module.redis-cluster[*].redis_endpoint
  description = "Redis endpoint address."
}

output "hostname" {
  value       = module.redis-cluster.hostname
  description = "DNS hostname"
}

output "redis_ssm_arn" {
  value       = module.redis-cluster.redis_ssm_name
  description = "A map of the names and ARNs created"
}

output "auth_token" {
  value     = module.redis-cluster.auth_token
  sensitive = true
}