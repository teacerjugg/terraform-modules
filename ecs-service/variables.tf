variable "name_prefix" {
  type     = string
  nullable = false
}

variable "cluster_id" {
  type     = string
  nullable = false
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "cpu_architecture" {
  type    = string
  default = "ARM64"

  validation {
    condition     = contains(["X86_64", "ARM64"], var.cpu_architecture)
    error_message = "cpu_architecture must be X86_64 or ARM64"
  }
}

variable "container_definitions" {
  type     = string
  nullable = false
}

variable "container_name" {
  type     = string
  nullable = false
}

variable "container_port" {
  type    = number
  default = 80
}

variable "track_latest" {
  type    = bool
  default = false
}

variable "subnets" {
  type     = list(string)
  nullable = false
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "target_group_arn" {
  type     = string
  nullable = false
}

variable "assign_public_ip" {
  type    = bool
  default = false
}

variable "enable_pull_through_cache" {
  type    = bool
  default = false
}
