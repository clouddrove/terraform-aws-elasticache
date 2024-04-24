output "id" {
  value       = module.memcached[*].id
  description = "memcached id."
}

output "tags" {
  value       = module.memcached.tags
  description = "A mapping of tags to assign to the resource."
}

output "memcached_endpoint" {
  value       = module.memcached.memcached_endpoint
  description = "Memcached endpoint address."
}

output "hostname" {
  value       = module.memcached.hostname
  description = "DNS hostname"
}

output "redis_ssm_arn" {
  value       = module.memcached.Memcached_ssm_name
  description = "A map of the names and ARNs created"
}
