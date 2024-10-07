## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alias | The display name of the alias. The name must start with the word `alias` followed by a forward slash. | `string` | `"alias/redis"` | no |
| allowed\_ip | List of allowed ip. | `list(any)` | `[]` | no |
| allowed\_ports | List of allowed ingress ports | `list(any)` | `[]` | no |
| auth\_token | The password used to access a password protected server. Can be specified only if transit\_encryption\_enabled = true. Find auto generated auth\_token in terraform.tfstate or in AWS SSM Parameter Store. | `string` | `null` | no |
| auth\_token\_enable | Flag to specify whether to create auth token (password) protected cluster. Can be specified only if transit\_encryption\_enabled = true. | `bool` | `true` | no |
| availability\_zones | A list of EC2 availability zones in which the replication group's cache clusters will be created. The order of the availability zones in the list is not important. | `list(string)` | n/a | yes |
| az\_mode | (Memcached only) Specifies whether the nodes in this Memcached node group are created in a single Availability Zone or created across multiple Availability Zones in the cluster's region. Valid values for this parameter are single-az or cross-az, default is single-az. If you want to choose cross-az, num\_cache\_nodes must be greater than 1. | `string` | `"single-az"` | no |
| cluster\_enabled | (Memcache only) Enabled or disabled cluster. | `bool` | `false` | no |
| cluster\_replication\_enabled | (Redis only) Enabled or disabled replication\_group for redis cluster. | `bool` | `false` | no |
| customer\_master\_key\_spec | Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms or signing algorithms that the key supports. Valid values: SYMMETRIC\_DEFAULT, RSA\_2048, RSA\_3072, RSA\_4096, ECC\_NIST\_P256, ECC\_NIST\_P384, ECC\_NIST\_P521, or ECC\_SECG\_P256K1. Defaults to SYMMETRIC\_DEFAULT. | `string` | `"SYMMETRIC_DEFAULT"` | no |
| deletion\_window\_in\_days | Duration in days after which the key is deleted after destruction of the resource. | `number` | `7` | no |
| egress\_rule | Enable to create egress rule | `bool` | `true` | no |
| enable | Enable or disable of elasticache | `bool` | `true` | no |
| enable\_key\_rotation | Specifies whether key rotation is enabled. | `string` | `true` | no |
| enable\_security\_group | Enable default Security Group with only Egress traffic allowed. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| extra\_tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`). | `map(string)` | `{}` | no |
| is\_enabled | Specifies whether the key is enabled. | `bool` | `true` | no |
| is\_external | enable to udated existing security Group | `bool` | `false` | no |
| key\_usage | Specifies the intended use of the key. Defaults to ENCRYPT\_DECRYPT, and only symmetric encryption and decryption are supported. | `string` | `"ENCRYPT_DECRYPT"` | no |
| kms\_description | The description of the key as viewed in AWS console. | `string` | `"Parameter Store KMS master key"` | no |
| kms\_key\_enabled | Specifies whether the kms is enabled or disabled. | `bool` | `true` | no |
| kms\_key\_id | The ARN of the key that you wish to use if encrypting at rest. If not supplied, uses service managed encryption. Can be specified only if at\_rest\_encryption\_enabled = true. | `string` | `""` | no |
| kms\_multi\_region | Indicates whether the KMS key is a multi-Region (true) or regional (false) key. | `bool` | `false` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list(any)` | <pre>[<br>  "environment",<br>  "name"<br>]</pre> | no |
| length | n/a | `number` | `25` | no |
| log\_delivery\_configuration | The log\_delivery\_configuration block allows the streaming of Redis SLOWLOG or Redis Engine Log to CloudWatch Logs or Kinesis Data Firehose. Max of 2 blocks. | `list(map(any))` | `[]` | no |
| managedby | ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'. | `string` | `"anmol@clouddrove.com"` | no |
| memcached\_route53\_record\_enabled | Whether to create Route53 record memcached set. | `bool` | `false` | no |
| memcached\_ssm\_parameter\_endpoint\_enabled | Name of the parameter. | `bool` | `false` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| network\_type | value of the network type. Valid values are ipv4, ipv6 or dual\_stack. | `string` | `"ipv4"` | no |
| num\_cache\_nodes | (Required unless replication\_group\_id is provided) The initial number of cache nodes that the cache cluster will have. For Redis, this value must be 1. For Memcache, this value must be between 1 and 20. If this number is reduced on subsequent runs, the highest numbered nodes will be removed. | `number` | `1` | no |
| protocol | The protocol. If not icmp, tcp, udp, or all use the. | `string` | `"tcp"` | no |
| replication\_group | n/a | `map(any)` | `{}` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/clouddrove/terraform-aws-elasticache"` | no |
| retention\_in\_days | Specifies the number of days you want to retain log events in the specified log group. | `number` | `0` | no |
| route53 | Route53 Configurations. | `map(any)` | `{}` | no |
| route53\_record\_enabled | Whether to create Route53 record set. | `bool` | `false` | no |
| security\_group\_names | A list of cache security group names to associate with this replication group. | `list(string)` | `null` | no |
| sg\_description | The security group description. | `string` | `"Instance default security group (only egress access is allowed)."` | no |
| sg\_egress\_description | Description of the egress and ingress rule | `string` | `"Description of the rule."` | no |
| sg\_egress\_ipv6\_description | Description of the egress\_ipv6 rule | `string` | `"Description of the rule."` | no |
| sg\_ids | of the security group id. | `list(any)` | `[]` | no |
| sg\_ingress\_description | Description of the ingress rule | `string` | `"Description of the ingress rule use elasticache."` | no |
| snapshot\_arns | A single-element string list containing an Amazon Resource Name (ARN) of a Redis RDB snapshot file stored in Amazon S3. | `list(string)` | `null` | no |
| special | n/a | `bool` | `false` | no |
| ssm\_parameter\_description | SSM Parameters can be imported using. | `string` | `"Description of the parameter."` | no |
| ssm\_parameter\_endpoint\_enabled | Name of the parameter. | `bool` | `false` | no |
| ssm\_parameter\_type | Type of the parameter. | `string` | `"SecureString"` | no |
| subnet\_group\_description | Description for the cache subnet group. Defaults to `Managed by Terraform`. | `string` | `"The Description of the ElastiCache Subnet Group."` | no |
| subnet\_ids | List of VPC Subnet IDs for the cache subnet group. | `list(any)` | `[]` | no |
| user\_group\_ids | User Group ID to associate with the replication group. | `list(string)` | `null` | no |
| vpc\_id | The ID of the VPC that the instance security group belongs to. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| Memcached\_ssm\_name | A list of all of the parameter values |
| auth\_token | Auth token generated value |
| hostname | DNS hostname |
| id | Redis cluster id. |
| memcached\_arn | Memcached arn |
| memcached\_endpoint | Memcached endpoint address. |
| memcached\_hostname | DNS hostname |
| port | Redis port. |
| redis\_arn | Redis arn |
| redis\_endpoint | Redis endpoint address. |
| redis\_ssm\_name | A list of all of the parameter values |
| sg\_id | n/a |
| tags | A mapping of tags to assign to the resource. |
