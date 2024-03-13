##----------------------------------------------------------------------------------
## Labels module callled that will be used for naming and tags.
##----------------------------------------------------------------------------------
module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.0"

  enabled     = var.enable
  name        = var.name
  repository  = var.repository
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  extra_tags  = var.extra_tags
}

##----------------------------------------------------------------------------------
## Below resources will create SECURITY-GROUP and its components.
##----------------------------------------------------------------------------------
resource "aws_security_group" "default" {
  count = var.enable && var.enable_security_group && length(var.sg_ids) < 1 ? 1 : 0

  name        = format("%s-sg", module.labels.id)
  vpc_id      = var.vpc_id
  description = var.sg_description
  tags        = module.labels.tags
  lifecycle {
    create_before_destroy = true
  }
}

##----------------------------------------------------------------------------------
## Below resources will create SECURITY-GROUP-RULE and its components.
##----------------------------------------------------------------------------------
#tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group_rule" "egress" {
  count = (var.enable && var.enable_security_group == true && length(var.sg_ids) < 1 && var.is_external == false && var.egress_rule == true) ? 1 : 0

  description       = var.sg_egress_description
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default[*].id)
}
#tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group_rule" "egress_ipv6" {
  count = (var.enable && var.enable_security_group == true && length(var.sg_ids) < 1 && var.is_external == false) && var.egress_rule == true ? 1 : 0

  description       = var.sg_egress_ipv6_description
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = join("", aws_security_group.default[*].id)
}
resource "aws_security_group_rule" "ingress" {
  count = var.enable && length(var.allowed_ip) > 0 == true && length(var.sg_ids) < 1 ? length(compact(var.allowed_ports)) : 0

  description       = var.sg_ingress_description
  type              = "ingress"
  from_port         = element(var.allowed_ports, count.index)
  to_port           = element(var.allowed_ports, count.index)
  protocol          = var.protocol
  cidr_blocks       = var.allowed_ip
  security_group_id = join("", aws_security_group.default[*].id)
}

##----------------------------------------------------------------------------------
## Below resources will create KMS-KEY and its components.
##----------------------------------------------------------------------------------
resource "aws_kms_key" "default" {
  count = var.enable && var.kms_key_enabled && var.kms_key_id == "" ? 1 : 0

  description              = var.kms_description
  key_usage                = var.key_usage
  deletion_window_in_days  = var.deletion_window_in_days
  is_enabled               = var.is_enabled
  enable_key_rotation      = var.enable_key_rotation
  customer_master_key_spec = var.customer_master_key_spec
  policy                   = data.aws_iam_policy_document.default.json
  multi_region             = var.kms_multi_region
  tags                     = module.labels.tags
}

resource "aws_kms_alias" "default" {
  count = var.enable && var.kms_key_enabled && var.kms_key_id == "" ? 1 : 0

  name          = coalesce(var.alias, format("alias/%v", module.labels.id))
  target_key_id = var.kms_key_id == "" ? join("", aws_kms_key.default[*].id) : var.kms_key_id
}

##----------------------------------------------------------------------------------
## Data block called to get Permissions that will be used in creating policy.
##----------------------------------------------------------------------------------
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "default" {
  version = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        format(
          "arn:%s:iam::%s:root",
          join("", data.aws_partition.current[*].partition),
          data.aws_caller_identity.current.account_id
        )
      ]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

##----------------------------------------------------------------------------------
## Below resource will create will save logs cloudwatch_log_group resource for redis-cluster and memcached.
##----------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "default" {
  count             = var.enable && length(var.log_delivery_configuration) > 0 ? length(var.log_delivery_configuration) : 0
  name              = format("%s-%s", module.labels.name, var.log_delivery_configuration[count.index].log_type)
  retention_in_days = var.retention_in_days
  tags              = module.labels.tags
}


resource "aws_elasticache_subnet_group" "default" {
  count       = var.enable ? 1 : 0
  name        = format("%s-subnet-group", module.labels.id)
  subnet_ids  = var.subnet_ids
  description = var.subnet_group_description

  tags = module.labels.tags
}

##----------------------------------------------------------------------------------
## Below resource will create random passoword for the auth_token
##----------------------------------------------------------------------------------

resource "random_password" "auth_token" {
  count   = var.enable && var.auth_token_enable && var.auth_token == null ? 1 : 0
  length  = var.length
  special = var.special
}

##----------------------------------------------------------------------------------
## Below resource will create replication-group resource for redis-cluster and memcached.
##----------------------------------------------------------------------------------
resource "aws_elasticache_replication_group" "cluster" {
  count = var.enable && var.cluster_replication_enabled ? 1 : 0

  engine                     = lookup(var.replication_group, "engine", "")
  replication_group_id       = module.labels.id
  description                = lookup(var.replication_group, "replication_group_description", "User-created description for the replication group.")
  engine_version             = lookup(var.replication_group, "engine_version", "")
  port                       = lookup(var.replication_group, "port", "")
  parameter_group_name       = lookup(var.replication_group, "parameter_group_name", "default.redis5.0")
  node_type                  = lookup(var.replication_group, "node_type", "cache.t2.small")
  automatic_failover_enabled = lookup(var.replication_group, "automatic_failover_enabled", true)
  subnet_group_name          = join("", aws_elasticache_subnet_group.default[*].name)
  security_group_ids         = length(var.sg_ids) < 1 ? aws_security_group.default[*].id : var.sg_ids
  security_group_names       = var.security_group_names
  snapshot_arns              = var.snapshot_arns
  snapshot_name              = lookup(var.replication_group, "snapshot_name", "")
  notification_topic_arn     = lookup(var.replication_group, "notification_topic_arn", "")
  snapshot_window            = lookup(var.replication_group, "snapshot_window", null)
  final_snapshot_identifier  = lookup(var.replication_group, "final_snapshot_identifier", null)
  snapshot_retention_limit   = lookup(var.replication_group, "snapshot_retention_limit", "0")
  apply_immediately          = lookup(var.replication_group, "apply_immediately", false)
  auto_minor_version_upgrade = lookup(var.replication_group, "auto_minor_version_upgrade", true)
  maintenance_window         = lookup(var.replication_group, "maintenance_window", "sun:05:00-sun:06:00")
  at_rest_encryption_enabled = lookup(var.replication_group, "at_rest_encryption_enabled", true)
  transit_encryption_enabled = lookup(var.replication_group, "transit_encryption_enabled", true)
  multi_az_enabled           = lookup(var.replication_group, "multi_az_enabled", false)
  network_type               = var.network_type

  auth_token         = var.auth_token_enable ? (var.auth_token == null ? random_password.auth_token[0].result : var.auth_token) : ""
  kms_key_id         = var.kms_key_id == "" ? join("", aws_kms_key.default[*].arn) : var.kms_key_id
  tags               = module.labels.tags
  num_cache_clusters = lookup(var.replication_group, "num_cache_clusters", 1)
  user_group_ids     = var.user_group_ids

  dynamic "log_delivery_configuration" {
    for_each = var.log_delivery_configuration

    content {
      destination      = lookup(log_delivery_configuration.value, "destination", aws_cloudwatch_log_group.default[index(var.log_delivery_configuration, log_delivery_configuration.value)].name)
      destination_type = lookup(log_delivery_configuration.value, "destination_type", null)
      log_format       = lookup(log_delivery_configuration.value, "log_format", null)
      log_type         = lookup(log_delivery_configuration.value, "log_type", null)
    }
  }
}

##----------------------------------------------------------------------------------
## Below resource will create cluster.
##----------------------------------------------------------------------------------
resource "aws_elasticache_cluster" "default" {
  count                        = var.enable && var.cluster_enabled ? 1 : 0
  engine                       = lookup(var.replication_group, "engine", "")
  cluster_id                   = module.labels.id
  engine_version               = lookup(var.replication_group, "engine_version", "")
  port                         = lookup(var.replication_group, "port", "")
  num_cache_nodes              = var.num_cache_nodes
  az_mode                      = var.az_mode
  parameter_group_name         = lookup(var.replication_group, "parameter_group_name", "default.redis5.0")
  node_type                    = lookup(var.replication_group, "node_type", "cache.t2.small")
  subnet_group_name            = join("", aws_elasticache_subnet_group.default[*].name)
  security_group_ids           = length(var.sg_ids) < 1 ? aws_security_group.default[*].id : var.sg_ids
  snapshot_arns                = var.snapshot_arns
  snapshot_name                = lookup(var.replication_group, "snapshot_name", "")
  notification_topic_arn       = lookup(var.replication_group, "notification_topic_arn", "")
  snapshot_window              = lookup(var.replication_group, "snapshot_window", null)
  snapshot_retention_limit     = lookup(var.replication_group, "snapshot_retention_limit", "0")
  apply_immediately            = lookup(var.replication_group, "apply_immediately", false)
  preferred_availability_zones = slice(var.availability_zones, 0, var.num_cache_nodes)
  maintenance_window           = lookup(var.replication_group, "maintenance_window", "sun:05:00-sun:06:00")
  network_type                 = var.network_type
  tags                         = module.labels.tags

}

##----------------------------------------------------------------------------------
## Below resource will create ROUTE-53 resource for redis and memcached.
##----------------------------------------------------------------------------------
resource "aws_route53_record" "elasticache" {
  count = var.enable && var.route53_record_enabled ? 1 : 0

  name    = lookup(var.route53, "dns_record_name", "elasticache")
  type    = lookup(var.route53, "route53_type", "")
  ttl     = lookup(var.route53, "route53_ttl", null)
  zone_id = lookup(var.route53, "route53_zone_id", null)
  records = lookup(var.replication_group, "automatic_failover_enabled", true) ? [aws_elasticache_replication_group.cluster[0].configuration_endpoint_address] : [aws_elasticache_replication_group.cluster[0].primary_endpoint_address]
}

##----------------------------------------------------------------------------------
## Below resource will create ssm-parameter resource for redis and memcached with auth-token.
##----------------------------------------------------------------------------------
resource "aws_ssm_parameter" "secret" {
  count = var.enable && var.auth_token_enable ? 1 : 0

  name        = format("/%s/%s/auth-token", var.environment, var.name)
  description = var.ssm_parameter_description
  type        = var.ssm_parameter_type
  value       = var.auth_token == null ? random_password.auth_token[0].result : var.auth_token
  key_id      = var.kms_key_id == "" ? join("", aws_kms_key.default[*].arn) : var.kms_key_id
}

##----------------------------------------------------------------------------------
## Below resource will create ssm-parameter resource for redis with endpoint.
##----------------------------------------------------------------------------------
resource "aws_ssm_parameter" "secret-endpoint" {
  count = var.enable && var.ssm_parameter_endpoint_enabled ? 1 : 0

  name        = format("/%s/%s/endpoint", var.environment, var.name)
  description = var.ssm_parameter_description
  type        = var.ssm_parameter_type
  value       = lookup(var.replication_group, "automatic_failover_enabled", true) ? [join("", aws_elasticache_replication_group.cluster[*].configuration_endpoint_address)][0] : [join("", aws_elasticache_replication_group.cluster[*].primary_endpoint_address)][0]
  key_id      = var.kms_key_id == "" ? join("", aws_kms_key.default[*].arn) : var.kms_key_id
}

##----------------------------------------------------------------------------------
## Below resource will create ROUTE-53 resource for memcached.
##----------------------------------------------------------------------------------
resource "aws_route53_record" "memcached_route_53" {
  count = var.enable && var.memcached_route53_record_enabled ? 1 : 0

  name    = lookup(var.route53, "dns_record_name", "")
  type    = lookup(var.route53, "route53_type", "A")
  ttl     = lookup(var.route53, "route53_ttl", 300)
  zone_id = lookup(var.route53, "route53_zone_id", null)
  records = aws_elasticache_cluster.default[*].configuration_endpoint
}

##----------------------------------------------------------------------------------
## Below resource will create ssm-parameter resource for memcached with endpoint.
##----------------------------------------------------------------------------------
resource "aws_ssm_parameter" "memcached_secret-endpoint" {
  count = var.enable && var.memcached_ssm_parameter_endpoint_enabled ? 1 : 0

  name        = format("/%s/%s/memcached-endpoint", var.environment, var.name)
  description = var.ssm_parameter_description
  type        = var.ssm_parameter_type
  value       = join("", aws_elasticache_cluster.default[*].configuration_endpoint)
  key_id      = var.kms_key_id == "" ? join("", aws_kms_key.default[*].arn) : var.kms_key_id
}
