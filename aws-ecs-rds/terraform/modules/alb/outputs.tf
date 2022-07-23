output "dns_name" {
  value = aws_alb.main.dns_name
}

output "zone_id" {
  value = aws_alb.main.zone_id
}

output "arn" {
  value = aws_alb.main.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.main.arn
}
