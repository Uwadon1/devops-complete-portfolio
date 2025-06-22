### Step 1: Copy Your App from Project 2

```bash
# Copy your application files
cp ../project-2-cicd-pipeline/app.js .
cp ../project-2-cicd-pipeline/package.json .
cp ../project-2-cicd-pipeline/Dockerfile .
```

# Project 3: Kubernetes Container Orchestration

Learn to run your web application on Kubernetes for scalability and reliability.

## What This Does

* Runs your app in multiple containers (pods)
* Automatically restarts failed containers
* Load balances traffic between containers
* Scales up/down based on demand
* Provides service discovery and networking

## Two Options: Local or AWS EKS

### Option A: Local Kubernetes (Recommended for learning)

* Uses Docker Desktop or Minikube
* Free and fast to set up
* Perfect for learning Kubernetes concepts

### Option B: AWS EKS (Optional, for production experience)

* Managed Kubernetes service on AWS
* Production-ready setup
* Costs money but more realistic

## Prerequisites

### For Local Kubernetes:

* [Docker Desktop](https://www.docker.com/products/docker-desktop) with Kubernetes enabled
* OR [Minikube](https://minikube.sigs.k8s.io/docs/start/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)

### For AWS EKS (Optional):

* [AWS CLI](https://aws.amazon.com/cli/) configured
* [eksctl](https://eksctl.io/introduction/#installation)
* AWS account (will incur costs)

## Option A: Local Kubernetes Setup

### 1. Enable Kubernetes in Docker Desktop

1. Open Docker Desktop
2. Go to Settings → Kubernetes
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"
5. Wait for green "Kubernetes is running" status

**OR setup Minikube:**

```bash
minikube start
minikube addons enable metrics-server

# Set up Docker environment
eval $(minikube docker-env)
```

### 2. Build Your Docker Image

```bash
docker build -t my-webapp:latest .
docker images | grep my-webapp
```

### 3. Deploy to Kubernetes

```bash
kubectl apply -f k8s/app.yaml
kubectl get pods
kubectl get services
kubectl get pods -w
```

### 4. Access Your Application

#### For Docker Desktop:

```bash
kubectl get services my-webapp-service
# Use the EXTERNAL-IP shown
```

#### For Minikube:

```bash
minikube service my-webapp-service --url
```

### 5. Test Kubernetes Features

**Scaling:**

```bash
kubectl scale deployment my-webapp --replicas=5
kubectl get pods -w
kubectl scale deployment my-webapp --replicas=2
```

**Self-healing:**

```bash
kubectl delete pod [POD-NAME]
kubectl get pods -w
```

**Rolling updates:**

```bash
kubectl set image deployment/my-webapp webapp=my-webapp:v2
kubectl rollout status deployment/my-webapp
```

## Option B: AWS EKS Setup (Optional)

### 1. Set Up EKS Cluster

```bash
chmod +x eks-setup.sh
./eks-setup.sh
```

### 2. Push Image to ECR

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin [ACCOUNT-ID].dkr.ecr.us-east-1.amazonaws.com
docker tag my-webapp:latest [ACCOUNT-ID].dkr.ecr.us-east-1.amazonaws.com/my-webapp:latest
docker push [ACCOUNT-ID].dkr.ecr.us-east-1.amazonaws.com/my-webapp:latest
```

### 3. Update EKS Configuration

```bash
# Edit k8s/app.yaml to use the ECR image
kubectl apply -f k8s/app.yaml
```

## Useful Kubernetes Commands

```bash
kubectl get all
kubectl describe pod [POD-NAME]
kubectl logs [POD-NAME]
kubectl logs -f [POD-NAME]
kubectl exec -it [POD-NAME] -- /bin/sh
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl port-forward service/my-webapp-service 8080:80
kubectl delete -f k8s/app.yaml
```

## Understanding the Configuration

### Deployment

* `replicas: 3`: Runs 3 copies of your app
* `resources`: CPU and memory limits
* `livenessProbe`: Restarts unhealthy containers
* `readinessProbe`: Sends traffic only to ready containers

### Service

* `type: LoadBalancer`: Exposes a public IP
* `port: 80`: External port
* `targetPort: 3001`: Internal app port

### ConfigMap

* Stores config data
* Mount as files or env vars
* Apply changes without image rebuild

### HPA (Horizontal Pod Autoscaler)

* `minReplicas: 2`, `maxReplicas: 10`
* `averageUtilization: 70`

## Troubleshooting

### Local Kubernetes

#### "No resources found"

```bash
kubectl cluster-info
kubectl config current-context
minikube status
```

#### "ImagePullBackOff"

```bash
eval $(minikube docker-env)
docker build -t my-webapp:latest .
docker images | grep my-webapp
```

#### "Pods stuck in Pending"

```bash
kubectl describe nodes
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Application Issues

#### "Can't access the app"

```bash
kubectl get services
minikube service my-webapp-service --url
kubectl get pods
kubectl logs [POD-NAME]
```

#### "Health checks failing"

```bash
kubectl logs [POD-NAME]
kubectl exec [POD-NAME] -- curl localhost:3001/health
kubectl port-forward [POD-NAME] 3001:3001
curl localhost:3001/health
```

### EKS Issues

#### "eksctl command not found"

```bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
```

#### "Cluster creation failed"

* Check AWS credentials: `aws sts get-caller-identity`
* Verify IAM permissions
* Check AWS service limits

## Clean Up

### Local Kubernetes:

```bash
kubectl delete -f k8s/app.yaml
minikube stop
minikube delete
```

### AWS EKS:

```bash
kubectl delete -f k8s/app.yaml
eksctl delete cluster --name my-webapp-cluster --region us-east-1
```

## What You Learned

✅ Kubernetes container orchestration
✅ Replica management and self-healing
✅ Load balancing and service discovery
✅ Config management via ConfigMaps
✅ Health checks and rolling updates
✅ Horizontal pod autoscaling
✅ (Optional) Production deployment with EKS

## Real-World Use Cases

* Microservices architecture
* High availability and zero-downtime deploys
* Traffic-based scaling
* Resilient production systems

## Next Steps

* Learn about Kubernetes namespaces
* Explore Helm for deployment automation
* Study Ingress controllers for routing
* Move on to Project 4: Monitoring and Observability

🎉 **Congratulations! You're now running scalable apps on Kubernetes!**
