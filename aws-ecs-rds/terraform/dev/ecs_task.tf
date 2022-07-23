module "ecs-bastion" {
  source                  = "../modules/ecs_task"
  env                     = local.env
  project                 = local.project
  task_role_arn           = module.iam_role_ecs_task_role.role_arn
  task_execution_role_arn = module.iam_role_ecs_task_execution_role.role_arn
  log_group_name          = local.log_group_bastion
  task_name               = "bastion"
  task_definition_json    = "task_definition.json"
  push_shell              = "push.sh"

  depends_on = [
    module.firehose_log_stream_ecs,
    module.ecr_bastion
  ]
}

