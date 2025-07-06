variable "vpc_id" {
  type     = string
  nullable = false
}

variable "service_name" {
  type     = string
  nullable = false
  default  = "com.amazonaws.ap-northeast-1.s3"
}

variable "route_table_ids" {
  type     = list(string)
  nullable = false
  default  = []
}

variable "tags" {
  type     = map(string)
  nullable = false
  default  = {}
}
