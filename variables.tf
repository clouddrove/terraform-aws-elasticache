variable "engine" {
  description = "The name of the cache engine to be used for the clusters in this replication group. e.g. redis"
  default = ""
}

variable "replication_group_id" {
  description = "The replication group identifier This parameter is stored as a lowercase string"
  default = ""
}

variable "engine_version" {
  description = "The version number of the cache engine to be used for the cache clusters in this replication group"
  default = ""
}
variable "port" {
  description = "the port number on which each of the cache nodes will accept connections"
  default = ""
}

variable "node_type" {
  description = "The compute and memory capacity of the nodes in the node group"
  default = ""
}


variable "security_group_ids" {
  description = "One or more VPC security groups associated with the cache cluster"
  default = []
}

variable "subnet_ids" {
  description = "List of VPC Subnet IDs for the cache subnet group"
  default =  []
}

variable "availability_zones" {
  type = "list"
  description = "(Optional) A list of EC2 availability zones in which the replication group's cache clusters will be created. The order of the availability zones in the list is not important"
}
variable "number_cache_clusters" {
  type = "string"
  description = "(Required for Cluster Mode Disabled) The number of cache clusters (primary and replicas) this replication group will have. If Multi-AZ is enabled, the value of this parameter must be at least 2. Updates will occur before other modifications"
  default =  ""
}
variable "auto_minor_version_upgrade" {
  description = "(Optional) Specifies whether a minor engine upgrades will be applied automatically to the underlying Cache Cluster instances during the maintenance window. Defaults to true"
  default =  ""
}
variable "organization" {
  type        = "string"
  description = "Organization (e.g. `cd` or `anmolnagpal`)"
}

variable "environment" {
  type        = "string"
  description = "Environment (e.g. `prod`, `dev`, `staging`)"
}

variable "name" {
  description = "Name  (e.g. `app` or `cluster`)"
  type        = "string"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `1`)"
}
variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)"
}

variable "maintenance_window" {
  default     = "sun:05:00-sun:06:00"
  description = "Maintenance window"
}

variable "at_rest_encryption_enabled" {
  default     = "false"
  description = "Enable encryption at rest"
}

variable "family" {
  description = "(Required) The family of the ElastiCache parameter group."
  default     = ""

}




