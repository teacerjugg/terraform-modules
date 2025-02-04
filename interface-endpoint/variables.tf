variable "vpc_id" {
  type     = string
  nullable = false
}

variable "service_names" {
  type     = set(string)
  nullable = false
  default  = []

  validation {
    condition = alltrue([
      for v in var.service_names : can(regex("^com.amazonaws..+$", v))
    ])
    error_message = "invalid service_name format"
  }
}

variable "subnet_ids" {
  type     = list(string)
  nullable = false
  default  = []
}

variable "security_group_ids" {
  type     = list(string)
  nullable = false
  default  = []
}

variable "private_dns_enabled" {
  type    = bool
  default = true
}


variable "tags" {
  type     = map(string)
  nullable = true
  default  = null
}
