variable "name_prefix" {
  type     = string
  nullable = false
}

variable "secrets" {
  type    = map(string)
  default = {}
}
