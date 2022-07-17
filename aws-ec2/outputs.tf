output "training_ec2_ip" {
  value = aws_instance.training_ec2.public_dns
}
