variable "name_prefix" {
  type     = string
  nullable = false
}

variable "vpc_id" {
  type     = string
  nullable = false
}

variable "ingress_rules" {
  type = map(object({
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    from_port                    = number
    to_port                      = number
    ip_protocol                  = optional(string, "tcp")
  }))
  default = {}
}

variable "egress_rules" {
  type = map(object({
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    from_port                    = number
    to_port                      = number
    ip_protocol                  = optional(string, "tcp")
  }))
  default = {}
}
