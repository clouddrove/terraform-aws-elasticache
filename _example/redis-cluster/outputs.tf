output "id" {
  value       = module.redis-cluster.id
  description = "Redis cluster id."
}

output "tags" {
  value       = module.redis-cluster.tags
  description = "A mapping of tags to assign to the resource."
}

output "redis_endpoint" {
  value       = module.redis-cluster.redis_endpoint
  description = "Redis endpoint address."
}