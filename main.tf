module "label" {
  source       = "git::https://github.com/clouddrove/terraform-lables.git?ref=tags/0.11.0"
  organization = "${var.organization}"
  name         = "${var.name}"
  environment  = "${var.environment}"
  delimiter    = "${var.delimiter}"
  attributes   = "${var.attributes}"
  tags         = "${var.tags}"
}
resource "aws_elasticache_subnet_group" "redis" {
  name        = "${module.label.id}"
  subnet_ids  = ["${var.subnet_ids}"]
  description = "Managed by Clouddrove"
}

resource "aws_elasticache_parameter_group" "default" {
  name         = "${module.label.id}"
  family       = "${var.family}"
  description  = "Managed by Clouddrove"
}


resource "aws_elasticache_replication_group" "redis" {
  engine                        = "${var.engine}"
  replication_group_id          = "${module.label.id}"
  replication_group_description = "${module.label.id}"
  engine_version                = "${var.engine_version}"
  port                          = "${var.port}"
  parameter_group_name          = "${aws_elasticache_parameter_group.default.id}"
  node_type                     = "${var.node_type}"
  automatic_failover_enabled    = false
  subnet_group_name             = "${aws_elasticache_subnet_group.redis.name}"
  security_group_ids            = ["${var.security_group_ids}"]
  availability_zones            = ["${slice(var.availability_zones, 0, var.number_cache_clusters)}"]
  number_cache_clusters         =  "${var.number_cache_clusters}" #Required for Cluster Mode Disabled
  auto_minor_version_upgrade    = "${var.auto_minor_version_upgrade}"
  maintenance_window            = "${var.maintenance_window}"
  at_rest_encryption_enabled    = "${var.at_rest_encryption_enabled}"
  tags                          = "${module.label.tags}"

}

