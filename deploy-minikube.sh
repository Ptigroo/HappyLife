#!/bin/bash

# HappyLife Kubernetes Deployment Script for Minikube
# This script automates the deployment process

set -e  # Exit on error

echo "======================================"
echo "HappyLife Kubernetes Deployment Script"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Check if Minikube is running
echo "Checking Minikube status..."
if ! minikube status > /dev/null 2>&1; then
    echo -e "${YELLOW}Minikube is not running. Starting Minikube...${NC}"
    minikube start --cpus=4 --memory=8192 --driver=docker
    echo -e "${GREEN}Minikube started successfully${NC}"
else
    echo -e "${GREEN}Minikube is already running${NC}"
fi

# Configure Docker to use Minikube's daemon
echo ""
echo "Configuring Docker environment..."
eval $(minikube docker-env)
echo -e "${GREEN}Docker configured to use Minikube's daemon${NC}"

# Build Docker image
echo ""
echo "Building Docker image..."
docker build -t happylife-webapp:latest .
echo -e "${GREEN}Docker image built successfully${NC}"

# Check if namespace exists
echo ""
echo "Checking if namespace exists..."
if kubectl get namespace happylife > /dev/null 2>&1; then
    echo -e "${YELLOW}Namespace 'happylife' already exists${NC}"
    read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting existing namespace..."
        kubectl delete namespace happylife
        echo "Waiting for namespace to be fully deleted..."
        sleep 10
        echo -e "${GREEN}Namespace deleted${NC}"
    else
        echo -e "${YELLOW}Keeping existing namespace. Will update resources...${NC}"
    fi
else
    echo -e "${YELLOW}Namespace 'happylife' does not exist. Will create it...${NC}"
fi

# Check if API key is set in secret
echo ""
echo "Checking Azure API key configuration..."
if grep -q "YOUR_API_KEY_HERE" k8s/app-secret.yaml; then
    echo -e "${RED}ERROR: Azure API key not set in k8s/app-secret.yaml${NC}"
    echo "Please update the AZURE_DOC_INTEL_API_KEY value before deploying."
    exit 1
fi
echo -e "${GREEN}Azure API key is configured${NC}"

# Deploy Kubernetes resources
echo ""
echo "Deploying Kubernetes resources..."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/mysql-secret.yaml
kubectl apply -f k8s/app-secret.yaml
kubectl apply -f k8s/app-configmap.yaml
kubectl apply -f k8s/mysql-pvc.yaml
kubectl apply -f k8s/mysql-deployment.yaml
kubectl apply -f k8s/mysql-service.yaml
kubectl apply -f k8s/webapp-deployment.yaml
kubectl apply -f k8s/webapp-service.yaml

echo -e "${GREEN}All resources deployed successfully${NC}"

# Wait for MySQL to be ready
echo ""
echo "Waiting for MySQL to be ready (this may take a few minutes)..."
echo -e "${GRAY}Timeout: 5 minutes${NC}"
if kubectl wait --for=condition=ready pod -l app=mysql -n happylife --timeout=300s; then
    echo -e "${GREEN}MySQL is ready${NC}"
else
    echo -e "${YELLOW}WARNING: MySQL may not be ready yet. Checking status...${NC}"
    kubectl get pods -n happylife -l app=mysql
    echo -e "${GRAY}You can check logs with: kubectl logs -n happylife -l app=mysql${NC}"
fi

# Wait for webapp to be ready
echo ""
echo "Waiting for webapp to be ready (this may take a few minutes)..."
echo -e "${GRAY}Timeout: 5 minutes${NC}"
if kubectl wait --for=condition=ready pod -l app=webapp -n happylife --timeout=300s; then
    echo -e "${GREEN}Webapp is ready${NC}"
else
    echo -e "${YELLOW}WARNING: Webapp may not be ready yet. Checking status...${NC}"
    kubectl get pods -n happylife -l app=webapp
    echo -e "${GRAY}You can check logs with: kubectl logs -n happylife -l app=webapp${NC}"
fi

# Display deployment status
echo ""
echo "======================================"
echo "Deployment Status"
echo "======================================"
kubectl get all -n happylife

# Get service URL
echo ""
echo "======================================"
echo "Access Information"
echo "======================================"
MINIKUBE_IP=$(minikube ip)
echo -e "${GREEN}Application URL: http://${MINIKUBE_IP}:30080${NC}"
echo -e "${GREEN}Swagger UI:      http://${MINIKUBE_IP}:30080/swagger${NC}"
echo -e "${GREEN}Health Check:    http://${MINIKUBE_IP}:30080/health${NC}"
echo ""
echo -e "${CYAN}You can also use:${NC}"
echo "  minikube service webapp-service -n happylife"
echo ""
echo -e "${CYAN}To view logs:${NC}"
echo "  kubectl logs -n happylife -l app=webapp -f"
echo "  kubectl logs -n happylife -l app=mysql -f"
echo ""
echo -e "${CYAN}To access Kubernetes dashboard:${NC}"
echo "  minikube dashboard"
echo ""
echo -e "${CYAN}To scale the application:${NC}"
echo "  kubectl scale deployment webapp -n happylife --replicas=3"
echo ""
echo -e "${GREEN}Deployment completed successfully!${NC}"
