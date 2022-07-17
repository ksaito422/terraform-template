
####################################
# Auto Scaling
####################################

resource "aws_launch_configuration" "this" {
  image_id        = aws_ami_from_instance.this.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.ec2.id]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  launch_configuration = aws_launch_configuration.this.id
  min_size             = 1
  max_size             = 2

  target_group_arns   = [aws_lb_target_group.this.arn]
  vpc_zone_identifier = [aws_subnet.public_1.id, aws_subnet.public_2.id]
  health_check_type   = "ELB"
}
