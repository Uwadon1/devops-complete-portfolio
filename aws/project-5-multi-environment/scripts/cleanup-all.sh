#!/bin/bash
# Clean up all environments

set -e

echo "🧹 Cleaning up all environments"
echo "==============================="
echo ""
echo "⚠️  WARNING: This will DESTROY all resources!"
echo "This includes:"
echo "- Development environment"
echo "- Production environment"
echo "- All data and logs"
echo ""
echo "Are you sure you want to continue? (y/N)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled"
    exit 0
fi

# Cleanup development
echo "🗑️  Destroying development environment..."
cd environments/dev
if [ -f "terraform.tfstate" ]; then
    terraform destroy -auto-approve
    echo "✅ Development environment destroyed"
else
    echo "ℹ️  No development environment found"
fi
cd ../..

# Cleanup production
echo "🗑️  Destroying production environment..."
cd environments/prod
if [ -f "terraform.tfstate" ]; then
    terraform destroy -auto-approve
    echo "✅ Production environment destroyed"
else
    echo "ℹ️  No production environment found"
fi
cd ../..

echo ""
echo "🎉 All environments cleaned up!"
echo "Verify in AWS Console that all resources are deleted."