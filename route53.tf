
resource "aws_route53_zone" "route53_ecs" {
  name = var.main_host
}

resource "aws_route53_record" "frontend" {
  zone_id = aws_route53_zone.route53_ecs.zone_id
  name    = "*.${var.main_host}"
  type    = "A"
  alias {
    name                   = aws_lb.EcsAlb.dns_name
    zone_id                = aws_lb.EcsAlb.zone_id
    evaluate_target_health = true
  }
}
