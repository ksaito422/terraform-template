#/bin/bash -e

# ecs-execで接続するコンテナ環境の選択メニュー
PS3='In which environment do you want to ecs-exec the bastion task?: '
select ENV in "dev" "stg" "prod"
do
  if [ -z "$ENV" ]; then
    continue
  else
    break
  fi
done

PROJECT="dev-training"
CLUSTER_NAME="${PROJECT}-ecs-cluster-${ENV}"
TASK_DEFINITION_NAME="${PROJECT}-bastion-task-definition-${ENV}"
TASK_ID=$(aws ecs list-tasks --cluster ${CLUSTER_NAME} \
  --family ${TASK_DEFINITION_NAME} \
	--query "taskArns[0]" --output text \
  | awk '{count = split($1, arr, "/"); print arr[count]}')

# stg or prodのbastionコンテナに接続
aws ecs execute-command --cluster ${CLUSTER_NAME} \
	--task ${TASK_ID} \
	--container "bastion" \
	--interactive \
	--command "/bin/sh"
