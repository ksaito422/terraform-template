################################################################################
# ECS Cluster
################################################################################

resource "aws_ecs_cluster" "main" {
  name = "${var.project}-ecs-cluster-${var.env}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.env}-ecs-cluster"
  }
}

################################################################################
# Security Group for aws_ecs_service 
################################################################################

module "sg" {
  source = "../security_group"

  name          = "${var.project}-ecs-sg-${var.env}"
  vpc_id        = var.vpc_id
  sg_port_rules = var.sg_port_rules
}
