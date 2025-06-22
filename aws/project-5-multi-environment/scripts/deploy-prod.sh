#!/bin/bash
# Deploy to production environment

set -e

echo "🚀 Deploying to Production Environment"
echo "====================================="
echo ""
echo "⚠️  WARNING: This will deploy to PRODUCTION!"
echo "Make sure you have tested in development first."
echo ""
echo "Continue with production deployment? (y/N)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "❌ Production deployment cancelled"
    exit 0
fi

cd environments/prod

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
echo "📋 Planning production deployment..."
terraform plan -out=prod.tfplan

echo ""
echo "⚠️  FINAL CONFIRMATION: Deploy to PRODUCTION? (y/N)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "❌ Production deployment cancelled"
    exit 0
fi

# Apply the deployment
echo "🏗️  Deploying to production..."
terraform apply prod.tfplan

echo ""
echo "🎉 Production deployment complete!"
echo ""
terraform output next_steps

cd ../..