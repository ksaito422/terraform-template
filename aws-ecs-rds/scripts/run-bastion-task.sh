#/bin/bash -e

# 起動タスクの選択メニュー
PS3='In which environment do you want to start the bastion task?: '
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

# 最新のタスク定義を取得
TASK_DEFINITION=$(aws ecs list-task-definitions \
	--status active \
	--query "sort(taskDefinitionArns[?contains(@, '${TASK_DEFINITION_NAME}')])" \
  | jq -r 'sort | reverse[0]')

# subnetを取得
SUBNET_ID=$(aws ec2 describe-subnets \
	--query "Subnets" \
	--filters "Name=tag:Name,Values=${ENV}-public-subnet-ap-northeast-1a" \
  | jq -r '.[0].SubnetId')

# security groupsを取得
SG_ID=$(aws ec2 describe-security-groups \
	--query "SecurityGroups[].GroupId" \
	--filters "Name=tag:project,Values='training'" "Name=group-name,Values=${PROJECT}-ecs-sg-${ENV}" \
  --output text)

# # network config
NETWORK_CONFIG="awsvpcConfiguration={subnets=[${SUBNET_ID}],securityGroups=[${SG_ID}],assignPublicIp=ENABLED}"

# stg or prodにbastionコンテナの起動
aws ecs run-task --cluster "${CLUSTER_NAME}" \
	--enable-execute-command \
	--task-definition "${TASK_DEFINITION}" \
	--network-configuration "${NETWORK_CONFIG}" \
	--launch-type FARGATE \
  --tags key=env,value=${ENV} key=project,value=training key=Name,value=bastion-task-${ENV}
