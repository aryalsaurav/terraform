output "server_tg_arn" {
  value = aws_alb_target_group.server.arn
}

output "acm_validation_record" {
  value = {
    for dvo in aws_acm_certificate.server.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
}

output "alb_dns" {
  value = aws_lb.server.dns_name

}