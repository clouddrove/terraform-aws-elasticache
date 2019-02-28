output "id" {
  value       = "${join("", aws_elasticache_replication_group.redis.*.id)}"
  description = "Redis cluster id"
}



output "port" {
  value       = "${var.port}"
  description = "Redis port"
}
