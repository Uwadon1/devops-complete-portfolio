#!/bin/bash
# Deploy to development environment

set -e

echo "🚀 Deploying to Development Environment"
echo "======================================"

cd environments/dev

# Check if AWS CLI is configured
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "❌ AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ AWS CLI configured"

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Plan the deployment
echo "📋 Planning deployment..."
terraform plan -out=dev.tfplan

echo ""
echo "⚠️  Review the plan above. Proceed with deployment? (y/N)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled"
    exit 0
fi

# Apply the deployment
echo "🏗️  Deploying to development..."
terraform apply dev.tfplan

echo ""
echo "🎉 Development deployment complete!"
echo ""
terraform output next_steps

cd ../..