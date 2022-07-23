################################################################################
# ALB 
################################################################################

resource "aws_alb" "main" {
  name                       = "alb-${var.usage}-${var.env}"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = var.idle_timeout
  enable_deletion_protection = var.enable_deletion_protection

  subnets         = var.subnets
  security_groups = [module.sg.id]

  tags = {
    Name = "${var.env}-${var.usage}-alb"
  }
}

resource "aws_lb_target_group" "main" {
  name = "alb-tg-${var.usage}-${var.env}"

  target_type = "ip" # Fargateの場合ばipを指定
  # Fargateの場合ばvpc_id,port,protcolを設定する
  vpc_id               = var.vpc_id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = var.deregistration_delay

  health_check {
    path                = "/"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    port                = "traffic-port"
    timeout             = 5
    protocol            = "HTTP"
  }

  tags = {
    Name = "${var.env}-${var.usage}-alb-tg"
  }
}

################################################################################
# ALB Listener
################################################################################

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = {
    Name = "${var.env}-${var.usage}-http-alb-listener"
  }
}


resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.main.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.https_certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  depends_on = [
    var.dependency
  ]

  tags = {
    Name = "${var.env}-${var.usage}-https-alb-listener"
  }
}

################################################################################
# Security Group
################################################################################

module "sg" {
  source = "../security_group"

  name          = "${var.project}-alb-sg-${var.usage}-${var.env}"
  vpc_id        = var.vpc_id
  sg_port_rules = var.sg_port_rules
}
