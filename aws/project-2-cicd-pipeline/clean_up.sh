#!/bin/bash

# -------------------------
# AWS Cleanup Script
# -------------------------

set -e  # Exit on any error

# === CONFIGURATION ===
CLUSTER_NAME="webapp-cicd-cluster"
SERVICE_NAME="webapp-cicd-service"
TASK_FAMILY="webapp-cicd-task"
ECR_REPOSITORY="my-webapp"
LOG_GROUP_NAME="/ecs/$TASK_FAMILY"
SECURITY_GROUP_NAME="webapp-cicd-sg"
EXECUTION_ROLE_NAME="ecsTaskExecutionRole-$CLUSTER_NAME"
GITHUB_USER_NAME="github-actions-user"
AWS_REGION="us-west-2"

echo "=========================================="
echo "🚨 CLEANING UP AWS CI/CD RESOURCES"
echo "Region: $AWS_REGION"
echo "=========================================="

# Step 1: Stop and delete ECS service
echo "🧹 Deleting ECS Service (if exists)..."
aws ecs update-service \
  --cluster $CLUSTER_NAME \
  --service $SERVICE_NAME \
  --desired-count 0 \
  --region $AWS_REGION || echo "⚠️ ECS service update failed (may not exist)"

aws ecs delete-service \
  --cluster $CLUSTER_NAME \
  --service $SERVICE_NAME \
  --force \
  --region $AWS_REGION || echo "⚠️ ECS service delete failed (may not exist)"

# Step 2: Delete ECS cluster
echo "🧹 Deleting ECS Cluster..."
aws ecs delete-cluster \
  --cluster $CLUSTER_NAME \
  --region $AWS_REGION || echo "⚠️ ECS cluster delete failed (may not exist)"

# Step 3: Delete Task Definitions (all revisions)
echo "🧹 Deregistering Task Definitions..."
  TASK_DEFS=$(aws ecs list-task-definitions \
  --family-prefix $TASK_FAMILY \
  --region $AWS_REGION \
  --query 'taskDefinitionArns' \
  --output text)

if [ -n "$TASK_DEFS" ]; then
  for def in $TASK_DEFS; do
    aws ecs deregister-task-definition --task-definition "$def" --region $AWS_REGION
  done
else
  echo "⚠️ No task definitions to delete"
fi


# Step 4: Delete ECR repository
echo "🧹 Deleting ECR Repository..."
aws ecr delete-repository \
  --repository-name $ECR_REPOSITORY \
  --region $AWS_REGION \
  --force || echo "⚠️ ECR repository delete failed (may not exist)"

# Step 5: Delete CloudWatch log group
echo "🧹 Deleting CloudWatch Log Group..."
MSYS_NO_PATHCONV=1 aws logs delete-log-group \
  --log-group-name "$LOG_GROUP_NAME" \
  --region $AWS_REGION || echo "⚠️ Log group delete failed (may not exist)"

# Step 6: Delete IAM execution role
echo "🧹 Deleting IAM Role for ECS Tasks..."
aws iam detach-role-policy \
  --role-name $EXECUTION_ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy || echo "⚠️ Detach policy failed"

aws iam delete-role \
  --role-name $EXECUTION_ROLE_NAME || echo "⚠️ IAM role delete failed"

# Step 7: Delete GitHub IAM user and policies
echo "🧹 Deleting GitHub Actions IAM User..."
aws iam delete-access-key --user-name $GITHUB_USER_NAME --access-key-id $(aws iam list-access-keys --user-name $GITHUB_USER_NAME --query 'AccessKeyMetadata[0].AccessKeyId' --output text) || echo "⚠️ No access key to delete"

aws iam detach-user-policy \
  --user-name $GITHUB_USER_NAME \
  --policy-arn arn:aws:iam::aws:policy/AmazonECS_FullAccess || echo "⚠️ Detach ECS policy failed"

aws iam detach-user-policy \
  --user-name $GITHUB_USER_NAME \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess || echo "⚠️ Detach ECR policy failed"

aws iam delete-user --user-name $GITHUB_USER_NAME || echo "⚠️ IAM user delete failed"

echo "✅ All resources cleaned up successfully!"
