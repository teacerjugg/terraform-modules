variable "zone_name" {
  description = "The name of the Route53 zone"
  type        = string
  nullable    = false
}

variable "domain_name" {
  type     = string
  nullable = false
}

variable "sans" {
  type    = list(string)
  default = null
}
