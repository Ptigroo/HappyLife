# Makefile for HappyLife Kubernetes Deployment
# Provides convenient commands for managing the Kubernetes deployment

.PHONY: help start-minikube docker-env build deploy deploy-kustomize status logs clean restart scale dashboard ingress port-forward update

# Default target
help:
	@echo "HappyLife Kubernetes Deployment Commands"
	@echo "========================================"
	@echo ""
	@echo "Setup & Deployment:"
	@echo "  make start-minikube    - Start Minikube cluster"
	@echo "  make docker-env        - Configure Docker to use Minikube"
	@echo "  make build             - Build Docker image"
	@echo "  make deploy            - Deploy all resources to Kubernetes"
	@echo "  make deploy-kustomize  - Deploy using Kustomize"
	@echo "  make all               - Complete setup (start, build, deploy)"
	@echo ""
	@echo "Monitoring:"
	@echo "  make status            - Show deployment status"
	@echo "  make logs              - Show webapp logs"
	@echo "  make logs-mysql        - Show MySQL logs"
	@echo "  make pods              - List all pods"
	@echo "  make events            - Show recent events"
	@echo ""
	@echo "Access:"
	@echo "  make url               - Get application URL"
	@echo "  make open              - Open application in browser"
	@echo "  make port-forward      - Forward port 8080 to localhost"
	@echo "  make dashboard         - Open Kubernetes dashboard"
	@echo ""
	@echo "Management:"
	@echo "  make restart           - Restart webapp deployment"
	@echo "  make restart-mysql     - Restart MySQL deployment"
	@echo "  make scale REPLICAS=n  - Scale webapp to n replicas"
	@echo "  make update            - Rebuild and update deployment"
	@echo ""
	@echo "Ingress (Optional):"
	@echo "  make enable-ingress    - Enable Minikube ingress addon"
	@echo "  make deploy-ingress    - Deploy ingress resources"
	@echo ""
	@echo "Database:"
	@echo "  make mysql-shell       - Access MySQL shell"
	@echo "  make backup            - Backup MySQL database"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean             - Delete all resources"
	@echo "  make stop-minikube     - Stop Minikube cluster"
	@echo "  make delete-minikube   - Delete Minikube cluster"

# Start Minikube
start-minikube:
	@echo "Starting Minikube..."
	minikube start --cpus=4 --memory=8192 --driver=docker
	@echo "Minikube started successfully"

# Stop Minikube
stop-minikube:
	@echo "Stopping Minikube..."
	minikube stop

# Delete Minikube
delete-minikube:
	@echo "Deleting Minikube cluster..."
	minikube delete

# Configure Docker environment
docker-env:
	@echo "To configure Docker environment, run:"
	@echo "  eval \$$(minikube docker-env)  # Linux/Mac"
	@echo "  & minikube -p minikube docker-env --shell powershell | Invoke-Expression  # Windows"

# Build Docker image
build:
	@echo "Building Docker image..."
	@eval $$(minikube docker-env) && docker build -t happylife-webapp:latest .
	@echo "Docker image built successfully"

# Deploy all resources
deploy:
	@echo "Deploying Kubernetes resources..."
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/mysql-secret.yaml
	kubectl apply -f k8s/app-secret.yaml
	kubectl apply -f k8s/app-configmap.yaml
	kubectl apply -f k8s/mysql-pvc.yaml
	kubectl apply -f k8s/mysql-deployment.yaml
	kubectl apply -f k8s/mysql-service.yaml
	kubectl apply -f k8s/webapp-deployment.yaml
	kubectl apply -f k8s/webapp-service.yaml
	@echo "Waiting for pods to be ready..."
	kubectl wait --for=condition=ready pod -l app=mysql -n happylife --timeout=300s
	kubectl wait --for=condition=ready pod -l app=webapp -n happylife --timeout=300s
	@echo "Deployment completed successfully"

# Deploy using Kustomize
deploy-kustomize:
	@echo "Deploying using Kustomize..."
	kubectl apply -k k8s/
	@echo "Waiting for pods to be ready..."
	kubectl wait --for=condition=ready pod -l app=mysql -n happylife --timeout=300s
	kubectl wait --for=condition=ready pod -l app=webapp -n happylife --timeout=300s
	@echo "Deployment completed successfully"

# Complete setup
all: start-minikube docker-env build deploy status

# Show deployment status
status:
	@echo "Deployment Status:"
	@echo "=================="
	kubectl get all -n happylife

# List pods
pods:
	kubectl get pods -n happylife -o wide

# Show webapp logs
logs:
	kubectl logs -n happylife -l app=webapp --tail=100 -f

# Show MySQL logs
logs-mysql:
	kubectl logs -n happylife -l app=mysql --tail=100 -f

# Show events
events:
	kubectl get events -n happylife --sort-by='.lastTimestamp'

# Get application URL
url:
	@echo "Application URL:"
	@minikube service webapp-service -n happylife --url

# Open application in browser
open:
	minikube service webapp-service -n happylife

# Port forward to localhost
port-forward:
	@echo "Forwarding port 8080 to localhost..."
	@echo "Access application at http://localhost:8080"
	kubectl port-forward -n happylife service/webapp-service 8080:8080

# Restart webapp deployment
restart:
	@echo "Restarting webapp deployment..."
	kubectl rollout restart deployment webapp -n happylife
	kubectl rollout status deployment webapp -n happylife

# Restart MySQL deployment
restart-mysql:
	@echo "Restarting MySQL deployment..."
	kubectl rollout restart deployment mysql -n happylife
	kubectl rollout status deployment mysql -n happylife

# Scale webapp
scale:
	@if [ -z "$(REPLICAS)" ]; then \
		echo "Usage: make scale REPLICAS=n"; \
		exit 1; \
	fi
	@echo "Scaling webapp to $(REPLICAS) replicas..."
	kubectl scale deployment webapp -n happylife --replicas=$(REPLICAS)
	kubectl get pods -n happylife -l app=webapp

# Update deployment (rebuild and redeploy)
update: build
	@echo "Updating deployment..."
	kubectl delete pods -n happylife -l app=webapp
	@echo "Waiting for new pods to be ready..."
	kubectl wait --for=condition=ready pod -l app=webapp -n happylife --timeout=300s
	@echo "Update completed successfully"

# Enable Minikube ingress addon
enable-ingress:
	@echo "Enabling Minikube ingress addon..."
	minikube addons enable ingress
	@echo "Ingress addon enabled"

# Deploy ingress resources
deploy-ingress:
	@echo "Deploying ingress resources..."
	kubectl apply -f k8s/ingress.yaml
	@echo "Ingress deployed successfully"

# Access MySQL shell
mysql-shell:
	@POD=$$(kubectl get pods -n happylife -l app=mysql -o jsonpath='{.items[0].metadata.name}'); \
	echo "Connecting to MySQL in pod $$POD..."; \
	kubectl exec -it -n happylife $$POD -- mysql -u root -padmin HappyLifeDb

# Backup MySQL database
backup:
	@POD=$$(kubectl get pods -n happylife -l app=mysql -o jsonpath='{.items[0].metadata.name}'); \
	echo "Backing up database from pod $$POD..."; \
	kubectl exec -n happylife $$POD -- mysqldump -u root -padmin HappyLifeDb > backup-$$(date +%Y%m%d-%H%M%S).sql; \
	echo "Backup completed"

# Open Kubernetes dashboard
dashboard:
	minikube dashboard

# Clean up all resources
clean:
	@echo "Deleting all HappyLife resources..."
	kubectl delete namespace happylife
	@echo "Cleanup completed"

# Get information
info:
	@echo "Minikube Information:"
	@echo "====================="
	@echo "Status:"
	@minikube status
	@echo ""
	@echo "IP Address:"
	@minikube ip
	@echo ""
	@echo "Kubernetes Version:"
	@kubectl version --short
	@echo ""
	@echo "HappyLife Status:"
	@kubectl get all -n happylife 2>/dev/null || echo "Not deployed"
