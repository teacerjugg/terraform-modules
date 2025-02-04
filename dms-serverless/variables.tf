variable "name_prefix" {
  type     = string
  nullable = false
}

variable "endpoints" {
  type = map(object({
    endpoint_id                     = string
    endpoint_type                   = string
    database_name                   = optional(string)
    server_name                     = optional(string)
    engine_name                     = optional(string, "aurora")
    secrets_manager_access_role_arn = optional(string)
    secrets_manager_arn             = optional(string)
    username                        = optional(string)
    password                        = optional(string)
    port                            = optional(number, 3306)
    extra_connection_attributes     = optional(string)
    certificate_arn                 = optional(string)
    ssl_mode                        = optional(string, "none")
  }))
  default = {}
}

variable "replication_subnet_group_ids" {
  type    = list(string)
  default = []
}

variable "replication_subnet_group_description" {
  type    = string
  default = "Example description"
}


variable "replication_configs" {
  type = map(object({
    start_replication    = optional(bool, false)
    identifier           = string
    replication_type     = optional(string, "full-load-and-cdc")
    source_endpoint_key  = string
    target_endpoint_key  = string
    table_mappings       = string
    replication_settings = optional(string)

    compute_config = object({
      vpc_security_group_ids = list(string)
      min_capacity_units     = optional(number, 1)
      max_capacity_units     = optional(number, 8)
      multi_az               = optional(bool, false)
    })
  }))
  default = {}
}
