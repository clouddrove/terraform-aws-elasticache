#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/clouddrove/terraform-aws-elasticache"
  description = "Terraform current module repo"

  validation {
    condition     = can(regex("^https://", var.repository))
    error_message = "The module-repo value must be a valid Git repo link."
  }
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = ["environment", "name"]
  description = "Label order, e.g. `name`,`application`."
}

variable "extra_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "managedby" {
  type        = string
  default     = "anmol@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'."
}

variable "enable" {
  type        = bool
  default     = true
  description = "Enable or disable of elasticache"
}

variable "engine" {
  type        = string
  default     = ""
  description = "The name of the cache engine to be used for the clusters in this replication group. e.g. redis."
}

variable "automatic_failover_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether a read-only replica will be automatically promoted to read/write primary if the existing primary fails. If true, Multi-AZ is enabled for this replication group. If false, Multi-AZ is disabled for this replication group. Must be enabled for Redis (cluster mode enabled) replication groups. Defaults to false."
}

variable "engine_version" {
  type        = string
  default     = ""
  description = "The version number of the cache engine to be used for the cache clusters in this replication group."
}

variable "port" {
  type        = string
  default     = ""
  description = "the port number on which each of the cache nodes will accept connections."
  sensitive   = true
}

variable "user_group_ids" {
  type        = list(string)
  default     = [""]
  description = "User Group ID to associate with the replication group."
}

variable "node_type" {
  type        = string
  default     = "cache.t2.small"
  description = "The compute and memory capacity of the nodes in the node group."
}

variable "security_group_names" {
  type        = list(string)
  default     = null
  description = "A list of cache security group names to associate with this replication group."
}

variable "snapshot_arns" {
  type        = list(string)
  default     = null
  description = "A single-element string list containing an Amazon Resource Name (ARN) of a Redis RDB snapshot file stored in Amazon S3."
}

variable "snapshot_name" {
  type        = string
  default     = ""
  description = "The name of a snapshot from which to restore data into the new node group. Changing the snapshot_name forces a new resource."
  sensitive   = true
}

variable "snapshot_window" {
  type        = string
  default     = null
  description = "(Redis only) The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster. The minimum snapshot window is a 60 minute period."
}

variable "snapshot_retention_limit" {
  type        = string
  default     = "0"
  description = "(Redis only) The number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them. For example, if you set SnapshotRetentionLimit to 5, then a snapshot that was taken today will be retained for 5 days before being deleted. If the value of SnapshotRetentionLimit is set to zero (0), backups are turned off. Please note that setting a snapshot_retention_limit is not supported on cache.t1.micro or cache.t2.* cache nodes."
}

variable "notification_topic_arn" {
  type        = string
  default     = ""
  description = "An Amazon Resource Name (ARN) of an SNS topic to send ElastiCache notifications to."
  sensitive   = true
}

variable "apply_immediately" {
  type        = bool
  default     = false
  description = "Specifies whether any modifications are applied immediately, or during the next maintenance window. Default is false."
}

variable "subnet_ids" {
  type        = list(any)
  default     = []
  description = "List of VPC Subnet IDs for the cache subnet group."
  sensitive   = true
}

variable "subnet_group_description" {
  type        = string
  default     = "The Description of the ElastiCache Subnet Group."
  description = "Description for the cache subnet group. Defaults to `Managed by Terraform`."
}
variable "replication_group_description" {
  type        = string
  default     = "User-created description for the replication group."
  description = "Name of either the CloudWatch Logs LogGroup or Kinesis Data Firehose resource."
}

variable "availability_zones" {
  type        = list(string)
  description = "A list of EC2 availability zones in which the replication group's cache clusters will be created. The order of the availability zones in the list is not important."
}

variable "num_cache_clusters" {
  type        = number
  default     = 1
  description = "(Required for Cluster Mode Disabled) The number of cache clusters (primary and replicas) this replication group will have. If Multi-AZ is enabled, the value of this parameter must be at least 2. Updates will occur before other modifications."
}

variable "auto_minor_version_upgrade" {
  type        = bool
  default     = true
  description = "Specifies whether a minor engine upgrades will be applied automatically to the underlying Cache Cluster instances during the maintenance window. Defaults to true."
}

variable "maintenance_window" {
  type        = string
  default     = "sun:05:00-sun:06:00"
  description = "Maintenance window."
}

variable "at_rest_encryption_enabled" {
  type        = bool
  default     = true
  description = "Enable encryption at rest."
}

variable "transit_encryption_enabled" {
  type        = bool
  default     = true
  description = "Whether to enable encryption in transit."
}

variable "auth_token_enable" {
  type        = bool
  default     = true
  description = "Flag to specify whether to create auth token (password) protected cluster. Can be specified only if transit_encryption_enabled = true."
}

variable "auth_token" {
  type        = string
  default     = null
  description = "The password used to access a password protected server. Can be specified only if transit_encryption_enabled = true. Find auto generated auth_token in terraform.tfstate or in AWS SSM Parameter Store."
}

variable "cluster_replication_enabled" {
  type        = bool
  default     = false
  description = "(Redis only) Enabled or disabled replication_group for redis cluster."
}

# Module      : Cluster
# Description : Terraform cluster module variables.
variable "cluster_enabled" {
  type        = bool
  default     = false
  description = "(Memcache only) Enabled or disabled cluster."
}

variable "num_cache_nodes" {
  type        = number
  default     = 1
  description = "(Required unless replication_group_id is provided) The initial number of cache nodes that the cache cluster will have. For Redis, this value must be 1. For Memcache, this value must be between 1 and 20. If this number is reduced on subsequent runs, the highest numbered nodes will be removed."
}

variable "az_mode" {
  type        = string
  default     = "single-az"
  description = "(Memcached only) Specifies whether the nodes in this Memcached node group are created in a single Availability Zone or created across multiple Availability Zones in the cluster's region. Valid values for this parameter are single-az or cross-az, default is single-az. If you want to choose cross-az, num_cache_nodes must be greater than 1."
}

variable "parameter_group_name" {
  type        = string
  default     = "default.redis5.0"
  description = "The name of the parameter group to associate with this replication group. If this argument is omitted, the default cache parameter group for the specified engine is used."
}

variable "log_delivery_configuration" {
  type        = list(map(any))
  default     = []
  description = "The log_delivery_configuration block allows the streaming of Redis SLOWLOG or Redis Engine Log to CloudWatch Logs or Kinesis Data Firehose. Max of 2 blocks."
}

variable "retention_in_days" {
  type        = number
  default     = 0
  description = "Specifies the number of days you want to retain log events in the specified log group."
}

variable "multi_az_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether to enable Multi-AZ Support for the replication group. If true, automatic_failover_enabled must also be enabled. Defaults to false."

}

variable "kms_key_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether the kms is enabled or disabled."
}

variable "kms_key_id" {
  type        = string
  default     = ""
  description = "The ARN of the key that you wish to use if encrypting at rest. If not supplied, uses service managed encryption. Can be specified only if at_rest_encryption_enabled = true."
}

variable "alias" {
  type        = string
  default     = "alias/redis"
  description = "The display name of the alias. The name must start with the word `alias` followed by a forward slash."
}

variable "kms_description" {
  type        = string
  default     = "Parameter Store KMS master key"
  description = "The description of the key as viewed in AWS console."
}

variable "key_usage" {
  type        = string
  default     = "ENCRYPT_DECRYPT"
  sensitive   = true
  description = "Specifies the intended use of the key. Defaults to ENCRYPT_DECRYPT, and only symmetric encryption and decryption are supported."
}

variable "deletion_window_in_days" {
  type        = number
  default     = 7
  description = "Duration in days after which the key is deleted after destruction of the resource."
}

variable "is_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether the key is enabled."
}

variable "enable_key_rotation" {
  type        = string
  default     = true
  description = "Specifies whether key rotation is enabled."
}

variable "customer_master_key_spec" {
  type        = string
  default     = "SYMMETRIC_DEFAULT"
  description = "Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC_DEFAULT, RSA_2048, RSA_3072, RSA_4096, ECC_NIST_P256, ECC_NIST_P384, ECC_NIST_P521, or ECC_SECG_P256K1. Defaults to SYMMETRIC_DEFAULT."
  sensitive   = true
}

variable "kms_multi_region" {
  type        = bool
  default     = false
  description = "Indicates whether the KMS key is a multi-Region (true) or regional (false) key."
}
variable "vpc_id" {
  type        = string
  default     = ""
  description = "The ID of the VPC that the instance security group belongs to."
  sensitive   = true
}

variable "allowed_ip" {
  type        = list(any)
  default     = []
  description = "List of allowed ip."
}

variable "allowed_ports" {
  type        = list(any)
  default     = []
  description = "List of allowed ingress ports"
}

variable "protocol" {
  type        = string
  default     = "tcp"
  description = "The protocol. If not icmp, tcp, udp, or all use the."
}

variable "enable_security_group" {
  type        = bool
  default     = true
  description = "Enable default Security Group with only Egress traffic allowed."
}

variable "egress_rule" {
  type        = bool
  default     = true
  description = "Enable to create egress rule"
}

variable "is_external" {
  type        = bool
  default     = false
  description = "enable to udated existing security Group"
}

variable "sg_ids" {
  type        = list(any)
  default     = []
  description = "of the security group id."
}

variable "sg_description" {
  type        = string
  default     = "Instance default security group (only egress access is allowed)."
  description = "The security group description."
}
variable "sg_egress_description" {
  type        = string
  default     = "Description of the rule."
  description = "Description of the egress and ingress rule"
}

variable "sg_egress_ipv6_description" {
  type        = string
  default     = "Description of the rule."
  description = "Description of the egress_ipv6 rule"
}

variable "sg_ingress_description" {
  type        = string
  default     = "Description of the ingress rule use elasticache."
  description = "Description of the ingress rule"
}

##---------------------route53------------------------
variable "route53_record_enabled" {
  type        = bool
  default     = false
  description = "Whether to create Route53 record set."
}

variable "memcached_route53_record_enabled" {
  type        = bool
  default     = false
  description = "Whether to create Route53 record memcached set."
}

variable "route53_type" {
  type        = string
  default     = ""
  description = "The record type. Valid values are A, AAAA, CAA, CNAME, MX, NAPTR, NS, PTR, SOA, SPF, SRV and TXT. "
}

variable "route53_ttl" {
  type        = string
  default     = ""
  description = "(Required for non-alias records) The TTL of the record."
}

variable "dns_record_name" {
  type        = string
  default     = ""
  description = "The name of the record."
}

variable "route53_zone_id" {
  type        = string
  description = "Zone ID."
}

###------------------------------- ssm_parameter----------------------------

variable "ssm_parameter_endpoint_enabled" {
  type        = bool
  default     = false
  description = "Name of the parameter."
}

variable "memcached_ssm_parameter_endpoint_enabled" {
  type        = bool
  default     = false
  description = "Name of the parameter."
}

variable "ssm_parameter_description" {
  type        = string
  default     = "Description of the parameter."
  description = "SSM Parameters can be imported using."
}

variable "ssm_parameter_type" {
  type        = string
  default     = "SecureString"
  description = "Type of the parameter."
}

###------------------------------- random_password----------------------------

variable "length" {
  type    = number
  default = 25
}

variable "special" {
  type    = bool
  default = false

}
