resource "aws_security_group" "training_ec2_sg" {
  name        = "training-ec2-sg"
  description = "EC2 Security Group"
  vpc_id      = aws_vpc.training_vpc.id

  tags = {
    Name = "${local.env}-ec2-sg"
  }
}

resource "aws_security_group_rule" "training_ec2_in_http" {
  security_group_id = aws_security_group.training_ec2_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "training_ec2_out" {
  security_group_id = aws_security_group.training_ec2_sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_instance" "training_ec2" {
  ami           = "ami-0701e21c502689c31"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.training_subnet_a.id
  vpc_security_group_ids = [
    aws_security_group.training_ec2_sg.id,
  ]

  user_data = <<EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    uname -n > /var/www/html/index.html
    systemctl start httpd
    systemctl enable httpd
    EOF

  tags = {
    Name = "${local.env}-training-ec2"
  }
}

