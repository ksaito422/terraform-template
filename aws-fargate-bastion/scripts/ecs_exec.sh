#/bin/bash
TASK_ID=$1
PROJECT="fargate-bastion"
CLUSTER_NAME="${PROJECT}-cluster"

aws ecs execute-command --cluster ${CLUSTER_NAME} \
	--task ${TASK_ID} \
	--container "bastion" \
	--interactive \
	--command "/bin/sh"
