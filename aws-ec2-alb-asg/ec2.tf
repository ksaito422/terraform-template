####################################
# EC2
####################################

resource "aws_instance" "this" {
  ami           = "ami-0ab0bbbd329f565e6"
  instance_type = "t2.micro"
  key_name      = "example-test"
  subnet_id     = aws_subnet.public_1.id
  vpc_security_group_ids = [
    aws_security_group.ec2.id,
    # aws_security_group.alb.id
  ]

  user_data = file("./install.sh")

  tags = {
    Name = "${local.env}-ec2"
  }
}

