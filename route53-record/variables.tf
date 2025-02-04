variable "zone_name" {
  type        = string
  description = "Hosted zone domain name"
  nullable    = false
}

variable "host_name" {
  type        = string
  description = "Host name to create the record for"
  nullable    = false
}

variable "record_type" {
  type        = string
  description = "Type of record to create"
  default     = "A"
}

variable "ttl" {
  type    = number
  default = 3600
}

variable "records" {
  type        = list(string)
  description = "List of records to create for the domain"
  nullable    = false
}
