#!/bin/bash
# Get public URLs for all running applications

set -e

echo "🔍 Finding application URLs"
echo "=========================="

get_task_ip() {
    local cluster_name=$1
    local service_name=$2
    local env_name=$3
    
    echo "Checking $env_name environment..."
    
    # Get running task ARN
    task_arn=$(aws ecs list-tasks \
        --cluster "$cluster_name" \
        --service-name "$service_name" \
        --query 'taskArns[0]' \
        --output text 2>/dev/null)
    
    if [ "$task_arn" = "None" ] || [ "$task_arn" = "" ]; then
        echo "❌ No running tasks found in $env_name"
        return
    fi
    
    # Get network interface ID
    network_interface_id=$(aws ecs describe-tasks \
        --cluster "$cluster_name" \
        --tasks "$task_arn" \
        --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' \
        --output text 2>/dev/null)
    
    if [ "$network_interface_id" = "" ]; then
        echo "❌ Could not get network interface for $env_name"
        return
    fi
    
    # Get public IP
    public_ip=$(aws ec2 describe-network-interfaces \
        --network-interface-ids "$network_interface_id" \
        --query 'NetworkInterfaces[0].Association.PublicIp' \
        --output text 2>/dev/null)
    
    if [ "$public_ip" = "None" ] || [ "$public_ip" = "" ]; then
        echo "❌ No public IP found for $env_name"
        return
    fi
    
    echo "✅ $env_name: http://$public_ip"
    
    # Test if app is responding
    if curl -s --max-time 5 "http://$public_ip" >/dev/null 2>&1; then
        echo "   🟢 Application is responding"
    else
        echo "   🟡 Application may still be starting up"
    fi
}

# Check development environment
if [ -d "environments/dev" ]; then
    cd environments/dev
    if [ -f "terraform.tfstate" ]; then
        cluster_name=$(terraform output -raw cluster_name 2>/dev/null)
        service_name=$(terraform output -raw service_name 2>/dev/null)
        if [ "$cluster_name" != "" ] && [ "$service_name" != "" ]; then
            get_task_ip "$cluster_name" "$service_name" "Development"
        fi
    fi
    cd ../..
fi

echo ""

# Check production environment
if [ -d "environments/prod" ]; then
    cd environments/prod
    if [ -f "terraform.tfstate" ]; then
        cluster_name=$(terraform output -raw cluster_name 2>/dev/null)
        service_name=$(terraform output -raw service_name 2>/dev/null)
        if [ "$cluster_name" != "" ] && [ "$service_name" != "" ]; then
            get_task_ip "$cluster_name" "$service_name" "Production"
        fi
    fi
    cd ../..
fi

echo ""
echo "💡 Tip: If applications aren't responding, wait 2-3 minutes for containers to start"