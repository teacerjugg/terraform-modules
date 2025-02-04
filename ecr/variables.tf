variable "repository_name" {
  type     = string
  nullable = false
}

variable "force_delete" {
  type    = bool
  default = false
}

variable "dockerfile_path" {
  type     = string
  nullable = true
  default  = null
}

variable "platform" {
  type    = string
  default = "linux/arm64"
}

variable "tag" {
  type    = string
  default = "latest"
}
