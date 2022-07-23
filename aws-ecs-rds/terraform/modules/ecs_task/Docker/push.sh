#!/bin/bash -e
# Bastion imageのbuildとECR pushスクリプト

AWS_ACCOUNT_ID=$1
REGION=$2
ENV=$3

ECR_BASE_URI=${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com
ECR_PREFIX=${ECR_BASE_URI}/ecr

# login
aws ecr get-login-password --region ${REGION} \
	| docker login --username AWS --password-stdin ${ECR_BASE_URI}

# build
IMAGE_FULL_NAME="${ECR_PREFIX}-bastion-${ENV}"

# cd mysql_connector
docker build --platform linux/amd64 -t ${IMAGE_FULL_NAME}:${ENV} ./
docker push ${IMAGE_FULL_NAME}:${ENV}

