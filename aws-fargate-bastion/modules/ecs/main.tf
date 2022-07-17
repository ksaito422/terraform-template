data "aws_caller_identity" "current" {}

#######################################################################################
# Null Resource
# 初回イメージプッシュのみTerraformで実行するため
#######################################################################################

resource "null_resource" "main" {
  provisioner "local-exec" {
    working_dir = "${path.module}/Docker"
    # 第１引数にProject名、第2引数にアカウントIDを渡す
    command = "./push.sh ${var.project} ${data.aws_caller_identity.current.account_id}"
  }
}

#######################################################################################
# ECS
#######################################################################################

resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "app" {
  family        = "${var.prefix}-task-definition"
  task_role_arn = aws_iam_role.ecs_task_role.arn
  network_mode  = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  execution_role_arn = aws_iam_role.ecs_task_exec_role.arn
  memory             = "512"
  cpu                = "256"
  container_definitions = templatefile(
    "${path.module}/task_definition/task_definition.json",
    {
      IMAGE_PREFIX      = "${var.ecr_base_uri}/${var.project}"
      BASTION_LOG_GROUP = aws_cloudwatch_log_group.bastion.name
      REGION            = var.region
    }
  )
}

resource "aws_ecs_service" "main" {
  name                   = "${var.prefix}-service"
  cluster                = aws_ecs_cluster.main.id
  task_definition        = aws_ecs_task_definition.app.arn
  desired_count          = 1
  enable_execute_command = true
  launch_type            = "FARGATE"
  platform_version       = "LATEST"
  network_configuration {
    subnets          = var.subnet
    security_groups  = [aws_security_group.main.id]
    assign_public_ip = false
  }

  tags = {
    Name = "${var.project}-ecs-service"
  }
}

#######################################################################################
# CloudWatch
#######################################################################################

resource "aws_cloudwatch_log_group" "bastion" {
  name              = "/ecs/${var.prefix}"
  retention_in_days = 1
}

#######################################################################################
# IAM
#######################################################################################

resource "aws_iam_role" "ecs_task_exec_role" {
  name               = "${var.prefix}-bastion-task-execution"
  assume_role_policy = file("${path.module}/iam/ecs_assume_policy.json")
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.prefix}-ecs-task"
  assume_role_policy = file("${path.module}/iam/ecs_assume_policy.json")
}

resource "aws_iam_policy" "bastion" {
  name   = "bastion-policy"
  path   = "/"
  policy = file("${path.module}/iam/ecs_task_role_policy.json")
}

data "aws_iam_policy" "ecs_task_exec_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CloudWatchLogの権限もタスク実行ロールに与える
data "aws_iam_policy" "cloudwatch" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_role_policy" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = data.aws_iam_policy.ecs_task_exec_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_logs_role_policy" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = data.aws_iam_policy.cloudwatch.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.bastion.arn
}

#######################################################################################
# SecurityGroup
#######################################################################################

resource "aws_security_group" "main" {
  name        = "${var.prefix}-ecs"
  description = "Egress TO DB"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

