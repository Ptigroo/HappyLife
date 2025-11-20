#!/bin/bash

# Cleanup script for HappyLife Kubernetes deployment

set -e

echo "======================================"
echo "HappyLife Kubernetes Cleanup Script"
echo "======================================"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}This will delete all HappyLife resources from Kubernetes${NC}"
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled"
    exit 0
fi

# Delete namespace (this will delete everything in it)
echo ""
echo "Deleting namespace and all resources..."
kubectl delete namespace happylife

echo ""
echo -e "${GREEN}Cleanup completed successfully!${NC}"
echo ""
echo "To also clean up Minikube:"
echo "  minikube stop    # Stop Minikube"
echo "  minikube delete  # Delete Minikube cluster"
