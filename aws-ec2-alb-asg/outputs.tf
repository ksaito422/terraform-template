output "ip" {
  value = aws_instance.this.public_ip
}

output "lb_address" {
  value = aws_lb.this.dns_name
}
