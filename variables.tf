#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "application" {
  type        = string
  default     = ""
  description = "Application (e.g. `cd` or `clouddrove`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "attributes" {
  type        = list
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "tags" {
  type        = map
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

# Module      : Replication Group
# Description : Terraform Replication group module variables.
variable "engine" {
  default     = ""
  description = "The name of the cache engine to be used for the clusters in this replication group. e.g. redis."
}

variable "replication_group_id" {
  default     = ""
  description = "The replication group identifier This parameter is stored as a lowercase string."
}

variable "automatic_failover_enabled" {
  default     = false
  description = "Specifies whether a read-only replica will be automatically promoted to read/write primary if the existing primary fails. If true, Multi-AZ is enabled for this replication group. If false, Multi-AZ is disabled for this replication group. Must be enabled for Redis (cluster mode enabled) replication groups. Defaults to false."
}

variable "engine_version" {
  default     = ""
  description = "The version number of the cache engine to be used for the cache clusters in this replication group."
}

variable "port" {
  default     = ""
  description = "the port number on which each of the cache nodes will accept connections."
}

variable "node_type" {
  default     = ""
  description = "The compute and memory capacity of the nodes in the node group."
}

variable "security_group_ids" {
  default     = []
  description = "One or more VPC security groups associated with the cache cluster."
}

variable "security_group_names" {
  default     = null
  description = "A list of cache security group names to associate with this replication group."
}

variable "snapshot_arns" {
  default     = null
  description = "A single-element string list containing an Amazon Resource Name (ARN) of a Redis RDB snapshot file stored in Amazon S3."
}

variable "snapshot_name" {
  default     = ""
  description = "The name of a snapshot from which to restore data into the new node group. Changing the snapshot_name forces a new resource."
}

variable "snapshot_window" {
  default     = null
  description = "(Redis only) The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your cache cluster. The minimum snapshot window is a 60 minute period."
}

variable "snapshot_retention_limit" {
  default     = 0
  description = "(Redis only) The number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them. For example, if you set SnapshotRetentionLimit to 5, then a snapshot that was taken today will be retained for 5 days before being deleted. If the value of SnapshotRetentionLimit is set to zero (0), backups are turned off. Please note that setting a snapshot_retention_limit is not supported on cache.t1.micro or cache.t2.* cache nodes."
}

variable "notification_topic_arn" {
  default     = ""
  description = "An Amazon Resource Name (ARN) of an SNS topic to send ElastiCache notifications to."
}

variable "apply_immediately" {
  default     = false
  description = "Specifies whether any modifications are applied immediately, or during the next maintenance window. Default is false."
}

variable "subnet_ids" {
  default     = []
  description = "List of VPC Subnet IDs for the cache subnet group."
}

variable "availability_zones" {
  type        = list(string)
  description = "A list of EC2 availability zones in which the replication group's cache clusters will be created. The order of the availability zones in the list is not important."
}

variable "number_cache_clusters" {
  type        = string
  default     = ""
  description = "(Required for Cluster Mode Disabled) The number of cache clusters (primary and replicas) this replication group will have. If Multi-AZ is enabled, the value of this parameter must be at least 2. Updates will occur before other modifications."
}

variable "auto_minor_version_upgrade" {
  default     = true
  description = "Specifies whether a minor engine upgrades will be applied automatically to the underlying Cache Cluster instances during the maintenance window. Defaults to true."
}

variable "maintenance_window" {
  default     = "sun:05:00-sun:06:00"
  description = "Maintenance window."
}

variable "at_rest_encryption_enabled" {
  default     = false
  description = "Enable encryption at rest."
}

variable "transit_encryption_enabled" {
  default     = false
  description = "Whether to enable encryption in transit."
}

variable "auth_token" {
  default     = null
  description = "The password used to access a password protected server. Can be specified only if transit_encryption_enabled = true."
}

variable "family" {
  default     = ""
  description = "(Required) The family of the ElastiCache parameter group."
}

variable "replication_enabled" {
  type        = bool
  default     = false
  description = "(Redis only) Enabled or disabled replication_group for redis standalone instance."
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
  default     = 1
  description = "(Required unless replication_group_id is provided) The initial number of cache nodes that the cache cluster will have. For Redis, this value must be 1. For Memcache, this value must be between 1 and 20. If this number is reduced on subsequent runs, the highest numbered nodes will be removed."
}

variable "az_mode" {
  default     = "single-az"
  description = "(Memcached only) Specifies whether the nodes in this Memcached node group are created in a single Availability Zone or created across multiple Availability Zones in the cluster's region. Valid values for this parameter are single-az or cross-az, default is single-az. If you want to choose cross-az, num_cache_nodes must be greater than 1."
}


variable "replicas_per_node_group" {
  default     = ""
  description = "Replicas per Shard."
}

variable "num_node_groups" {
  default     = ""
  description = "Number of Shards (nodes)."
}