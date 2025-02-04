data "aws_route53_zone" "this" {
  name         = var.zone_name
  private_zone = false
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "${var.host_name}.${var.zone_name}"
  type    = var.record_type
  ttl     = var.ttl

  records = var.records
}
