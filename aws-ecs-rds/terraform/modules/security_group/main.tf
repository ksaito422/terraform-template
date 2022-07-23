resource "aws_security_group" "main" {
  name   = var.name
  vpc_id = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress" {
  count = length(var.sg_port_rules)

  type        = "ingress"
  from_port   = var.sg_port_rules[count.index].from_port
  to_port     = var.sg_port_rules[count.index].to_port
  protocol    = "tcp"
  cidr_blocks = var.sg_port_rules[count.index].cidr_blocks

  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.main.id
}
