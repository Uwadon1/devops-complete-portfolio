#!/bin/bash

# -------------------------
# AWS Cleanup Script - Updated and Hardened
# -------------------------

set -e

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

# Step 1: Stop and delete ECS Service
echo "🧹 Deleting ECS Service..."
aws ecs update-service \
  --cluster "$CLUSTER_NAME" \
  --service "$SERVICE_NAME" \
  --desired-count 0 \
  --region "$AWS_REGION" || echo "⚠️ Service update skipped"

aws ecs delete-service \
  --cluster "$CLUSTER_NAME" \
  --service "$SERVICE_NAME" \
  --force \
  --region "$AWS_REGION" || echo "⚠️ Service delete skipped"

# Step 2: Delete ECS Cluster
echo "🧹 Deleting ECS Cluster..."
aws ecs delete-cluster \
  --cluster "$CLUSTER_NAME" \
  --region "$AWS_REGION" || echo "⚠️ Cluster delete skipped"

# Step 3: Deregister all Task Definitions
echo "🧹 Deregistering all task definitions..."
TASK_DEFS=$(aws ecs list-task-definitions \
  --family-prefix "$TASK_FAMILY" \
  --region "$AWS_REGION" \
  --query 'taskDefinitionArns' \
  --output text)

if [ -n "$TASK_DEFS" ]; then
  for def in $TASK_DEFS; do
    aws ecs deregister-task-definition --task-definition "$def" --region "$AWS_REGION"
    echo "✅ Deregistered: $def"
  done
else
  echo "⚠️ No task definitions found."
fi

# Step 4: Delete ECR Repository (and images)
echo "🧹 Deleting ECR Repository..."
aws ecr delete-repository \
  --repository-name "$ECR_REPOSITORY" \
  --region "$AWS_REGION" \
  --force || echo "⚠️ ECR delete skipped"

# Step 5: Delete CloudWatch Log Group
echo "🧹 Deleting CloudWatch Log Group..."
MSYS_NO_PATHCONV=1 aws logs delete-log-group \
  --log-group-name "$LOG_GROUP_NAME" \
  --region "$AWS_REGION" || echo "⚠️ Log group delete skipped"

# Step 6: Delete IAM Execution Role (detach all policies)
echo "🧹 Deleting ECS Execution Role..."
POLICIES=(
  "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
)

for policy in "${POLICIES[@]}"; do
  aws iam detach-role-policy \
    --role-name "$EXECUTION_ROLE_NAME" \
    --policy-arn "$policy" || echo "⚠️ Detach failed: $policy"
done

aws iam delete-role \
  --role-name "$EXECUTION_ROLE_NAME" || echo "⚠️ Execution role delete skipped"

# Step 7: Delete Security Group (if exists)
echo "🛡️ Deleting Security Group..."
SECURITY_GROUP_ID=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=$SECURITY_GROUP_NAME" \
  --query 'SecurityGroups[0].GroupId' \
  --output text 2>/dev/null)

if [ "$SECURITY_GROUP_ID" != "None" ] && [ -n "$SECURITY_GROUP_ID" ]; then
  aws ec2 delete-security-group \
    --group-id "$SECURITY_GROUP_ID" || echo "⚠️ Security group delete skipped"
  echo "✅ Security group deleted"
else
  echo "⚠️ Security group not found"
fi

# Step 8: Delete GitHub IAM User + Policies
echo "👤 Deleting GitHub IAM User and policies..."
ACCESS_KEYS=$(aws iam list-access-keys \
  --user-name "$GITHUB_USER_NAME" \
  --query 'AccessKeyMetadata[*].AccessKeyId' \
  --output text 2>/dev/null)

for key in $ACCESS_KEYS; do
  aws iam delete-access-key \
    --user-name "$GITHUB_USER_NAME" \
    --access-key-id "$key" || echo "⚠️ Failed to delete key: $key"
done

USER_POLICIES=(
  "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  "arn:aws:iam::aws:policy/IAMFullAccess"
)

for policy in "${USER_POLICIES[@]}"; do
  aws iam detach-user-policy \
    --user-name "$GITHUB_USER_NAME" \
    --policy-arn "$policy" || echo "⚠️ Failed to detach $policy"
done

aws iam delete-user --user-name "$GITHUB_USER_NAME" || echo "⚠️ IAM user delete skipped"

echo ""
echo "=========================================="
echo "✅ ALL RESOURCES CLEANED UP SUCCESSFULLY!"
echo "=========================================="
