output "tags" {
  value       = module.memcached.tags
  description = "A mapping of tags to assign to the resource."
}

output "memcached_endpoint" {
  value       = module.memcached.memcached_endpoint
  description = "Memcached endpoint address."
}

