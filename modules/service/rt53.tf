resource "aws_route53_record" "this" {
  count = var.route53_hosted_zone_id == "" ? 0 : 1
  allow_overwrite = true
  zone_id         = "${var.route53_hosted_zone_id}"
  name            = "${var.route53_record_name}"
  type            = "A"
  alias {
    name                   = "dualstack.${aws_elb.this.dns_name}"
    zone_id                = "${aws_elb.this.zone_id}"
    evaluate_target_health = false #lb itself has health check eval 
  }
}