locals {
  ecr_base_uri = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

################################################################################
# ECS task definition bastion
################################################################################

resource "aws_ecs_task_definition" "main" {
  family             = "${var.project}-${var.task_name}-task-definition-${var.env}"
  task_role_arn      = var.task_role_arn
  execution_role_arn = var.task_execution_role_arn
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]

  memory = 512
  cpu    = 256

  container_definitions = templatefile(
    "${path.module}/task_definition/${var.task_definition_json}",
    {
      IMAGE_PREFIX      = "${local.ecr_base_uri}/ecr"
      BASTION_LOG_GROUP = "${var.log_group_name}${var.env}"
      REGION            = data.aws_region.current.name
      ENV               = var.env
      UPPER_ENV         = upper(var.env)
    }
  )

  tags = {
    Name = "${var.env}-${var.task_name}-task-definition"
  }
}

################################################################################
# NullResource
# 初回apply時にbastion imageをpushする
################################################################################

resource "null_resource" "main" {
  provisioner "local-exec" {
    working_dir = "${path.module}/Docker"
    command     = "./${var.push_shell} ${data.aws_caller_identity.current.account_id} ${data.aws_region.current.name} ${var.env}"
  }
}

