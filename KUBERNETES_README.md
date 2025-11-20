# Kubernetes Deployment for HappyLife Application

This guide explains how to deploy the HappyLife application to Kubernetes using Minikube.

## Prerequisites

- [Minikube](https://minikube.sigs.k8s.io/docs/start/) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- [Docker](https://www.docker.com/products/docker-desktop) installed (for building images)

## Architecture

The Kubernetes deployment consists of:

- **Namespace**: `happylife` - Isolated namespace for all resources
- **MySQL Database**: StatefulSet with persistent storage
- **Web Application**: Deployment with 2 replicas for high availability
- **ConfigMaps**: Non-sensitive configuration
- **Secrets**: Sensitive data (passwords, API keys)
- **Services**: 
  - ClusterIP for MySQL (internal only)
  - NodePort for webapp (external access)
- **PersistentVolumeClaim**: 5Gi storage for MySQL data

## Quick Start

### 1. Start Minikube

```bash
# Start Minikube with sufficient resources
minikube start --cpus=4 --memory=8192 --driver=docker

# Verify Minikube is running
minikube status
```

### 2. Configure Docker Environment

To build images directly in Minikube's Docker daemon:

```bash
# Windows PowerShell
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

# Linux/Mac
eval $(minikube docker-env)

# Verify you're using Minikube's Docker
docker ps
```

### 3. Build the Application Image

```bash
# Build the Docker image in Minikube's environment
docker build -t happylife-webapp:latest .

# Verify the image exists
docker images | grep happylife
```

### 4. Update Secrets

**IMPORTANT**: Before deploying, update the Azure API key in `k8s/app-secret.yaml`:

```yaml
stringData:
  AZURE_DOC_INTEL_API_KEY: "YOUR_ACTUAL_API_KEY_HERE"
```

Alternatively, create the secret from command line:

```bash
kubectl create secret generic app-secret \
  --from-literal=AZURE_DOC_INTEL_API_KEY="your_actual_key" \
  --namespace=happylife \
  --dry-run=client -o yaml > k8s/app-secret.yaml
```

### 5. Deploy to Kubernetes

#### Option A: Using kubectl (recommended for beginners)

```bash
# Apply all manifests in order
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/mysql-secret.yaml
kubectl apply -f k8s/app-secret.yaml
kubectl apply -f k8s/app-configmap.yaml
kubectl apply -f k8s/mysql-pvc.yaml
kubectl apply -f k8s/mysql-deployment.yaml
kubectl apply -f k8s/mysql-service.yaml
kubectl apply -f k8s/webapp-deployment.yaml
kubectl apply -f k8s/webapp-service.yaml
```

#### Option B: Using Kustomize

```bash
# Deploy everything at once
kubectl apply -k k8s/

# Or using kustomize directly
kustomize build k8s/ | kubectl apply -f -
```

### 6. Wait for Deployment

```bash
# Watch the pods starting up
kubectl get pods -n happylife -w

# Check deployment status
kubectl get deployments -n happylife

# Check services
kubectl get services -n happylife
```

Wait until all pods show `Running` status and `READY` shows `1/1` or `2/2`.

### 7. Access the Application

#### Get the Application URL

```bash
# Get Minikube IP and service URL
minikube service webapp-service -n happylife --url

# Or open directly in browser
minikube service webapp-service -n happylife
```

The application will be accessible at: `http://<minikube-ip>:30080`

Example: `http://192.168.49.2:30080`

#### Alternative: Port Forwarding

```bash
# Forward local port 8080 to the service
kubectl port-forward -n happylife service/webapp-service 8080:8080

# Access at http://localhost:8080
```

## Kubernetes Commands

### View Resources

```bash
# View all resources in the namespace
kubectl get all -n happylife

# View pods with more details
kubectl get pods -n happylife -o wide

# View persistent volumes
kubectl get pvc -n happylife

# View secrets (names only, not values)
kubectl get secrets -n happylife

# View configmaps
kubectl get configmaps -n happylife
```

### View Logs

```bash
# View webapp logs
kubectl logs -n happylife -l app=webapp --tail=100 -f

# View MySQL logs
kubectl logs -n happylife -l app=mysql --tail=100 -f

# View logs for a specific pod
kubectl logs -n happylife <pod-name>

# View previous container logs (if pod crashed)
kubectl logs -n happylife <pod-name> --previous
```

### Debug Pods

```bash
# Describe a pod (see events and status)
kubectl describe pod -n happylife <pod-name>

# Execute commands in a pod
kubectl exec -n happylife <pod-name> -it -- /bin/bash

# Access MySQL shell
kubectl exec -n happylife <mysql-pod-name> -it -- mysql -u root -padmin HappyLifeDb

# Check webapp health endpoint
kubectl exec -n happylife <webapp-pod-name> -- curl http://localhost:8080/health
```

### Scale Application

```bash
# Scale webapp to 3 replicas
kubectl scale deployment webapp -n happylife --replicas=3

# Verify scaling
kubectl get pods -n happylife -l app=webapp
```

### Update Configuration

```bash
# Edit configmap
kubectl edit configmap app-config -n happylife

# Edit secret
kubectl edit secret app-secret -n happylife

# Restart pods to pick up changes
kubectl rollout restart deployment webapp -n happylife
```

### Restart Deployments

```bash
# Restart webapp deployment
kubectl rollout restart deployment webapp -n happylife

# Restart MySQL deployment
kubectl rollout restart deployment mysql -n happylife

# Check rollout status
kubectl rollout status deployment webapp -n happylife
```

## Update Application

### Rebuild and Redeploy

```bash
# 1. Ensure you're using Minikube's Docker
eval $(minikube docker-env)  # Linux/Mac
# or
& minikube -p minikube docker-env --shell powershell | Invoke-Expression  # Windows

# 2. Rebuild the image with same tag
docker build -t happylife-webapp:latest .

# 3. Delete existing pods to force image pull
kubectl delete pods -n happylife -l app=webapp

# Or force a rolling update
kubectl rollout restart deployment webapp -n happylife
```

### Update with Versioned Images (recommended for production)

```bash
# Build with version tag
docker build -t happylife-webapp:v1.0.1 .

# Update deployment to use new version
kubectl set image deployment/webapp webapp=happylife-webapp:v1.0.1 -n happylife

# Check rollout status
kubectl rollout status deployment webapp -n happylife

# Rollback if needed
kubectl rollout undo deployment webapp -n happylife
```

## Database Management

### Backup MySQL Data

```bash
# Create a backup
kubectl exec -n happylife <mysql-pod-name> -- mysqldump -u root -padmin HappyLifeDb > backup.sql

# Restore from backup
kubectl exec -i -n happylife <mysql-pod-name> -- mysql -u root -padmin HappyLifeDb < backup.sql
```

### Access MySQL CLI

```bash
# Get MySQL pod name
kubectl get pods -n happylife -l app=mysql

# Connect to MySQL
kubectl exec -it -n happylife <mysql-pod-name> -- mysql -u root -padmin

# Or directly access the database
kubectl exec -it -n happylife <mysql-pod-name> -- mysql -u root -padmin HappyLifeDb
```

## Troubleshooting

### Pods not starting

```bash
# Check pod status and events
kubectl describe pod -n happylife <pod-name>

# Check if image exists in Minikube
eval $(minikube docker-env)
docker images | grep happylife

# Check logs
kubectl logs -n happylife <pod-name>
```

### Database connection errors

```bash
# Check if MySQL is ready
kubectl get pods -n happylife -l app=mysql

# Check MySQL logs
kubectl logs -n happylife -l app=mysql

# Verify service is accessible
kubectl get svc -n happylife

# Test connection from webapp pod
kubectl exec -n happylife <webapp-pod-name> -- nc -zv mysql-service 3306
```

### Image pull errors

If you see `ImagePullBackOff` or `ErrImagePull`:

```bash
# Ensure you built the image in Minikube's Docker
eval $(minikube docker-env)
docker images | grep happylife

# The image should show "imagePullPolicy: IfNotPresent" in the deployment
kubectl get deployment webapp -n happylife -o yaml | grep imagePullPolicy
```

### Service not accessible

```bash
# Check service endpoints
kubectl get endpoints -n happylife

# Verify service configuration
kubectl describe service webapp-service -n happylife

# Get Minikube IP
minikube ip

# Check if NodePort is accessible
curl http://$(minikube ip):30080/health
```

### PVC stuck in Pending

```bash
# Check PVC status
kubectl describe pvc mysql-pvc -n happylife

# Check available storage classes
kubectl get storageclass

# Verify Minikube storage addon is enabled
minikube addons list | grep storage-provisioner
minikube addons enable storage-provisioner
```

## Clean Up

### Delete all resources

```bash
# Delete everything in the namespace
kubectl delete namespace happylife

# Or delete resources individually
kubectl delete -k k8s/

# Or manually
kubectl delete -f k8s/
```

### Clean up Minikube

```bash
# Stop Minikube
minikube stop

# Delete Minikube cluster
minikube delete

# Clean up Docker images (optional)
docker rmi happylife-webapp:latest
```

## Production Considerations

### Differences from Docker Compose

1. **Orchestration**: Kubernetes provides automatic healing, scaling, and rolling updates
2. **Load Balancing**: Built-in service discovery and load balancing
3. **Configuration Management**: Separate ConfigMaps and Secrets
4. **Storage**: Dynamic provisioning with PersistentVolumeClaims
5. **Health Checks**: Liveness and readiness probes for automatic recovery

### Moving to Production Kubernetes

For production deployment beyond Minikube:

1. **Use a real Kubernetes cluster** (AKS, EKS, GKE)
2. **Implement Ingress** instead of NodePort:
   ```bash
   # Enable ingress on Minikube for testing
   minikube addons enable ingress
   ```
3. **Use external database** services (e.g., Azure Database for MySQL)
4. **Implement proper secrets management** (Azure Key Vault, HashiCorp Vault)
5. **Add monitoring and logging** (Prometheus, Grafana, ELK stack)
6. **Use Helm charts** for easier deployment management
7. **Implement GitOps** (ArgoCD, Flux)
8. **Add resource quotas and limits**
9. **Configure network policies**
10. **Use private container registry** (Azure Container Registry)

### Enable Ingress (Optional)

For a more production-like setup with domain names:

```bash
# Enable ingress addon
minikube addons enable ingress

# Create ingress resource
kubectl apply -f k8s/ingress.yaml  # You'll need to create this

# Get Ingress IP
kubectl get ingress -n happylife

# Add to /etc/hosts (Linux/Mac) or C:\Windows\System32\drivers\etc\hosts (Windows)
# <minikube-ip> happylife.local
```

## Kubernetes Dashboard

```bash
# Start the dashboard
minikube dashboard

# Or get the URL
minikube dashboard --url
```

## Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Kustomize Documentation](https://kustomize.io/)

## Support

For issues specific to this deployment:
1. Check pod logs: `kubectl logs -n happylife <pod-name>`
2. Check events: `kubectl get events -n happylife --sort-by='.lastTimestamp'`
3. Describe resources: `kubectl describe <resource-type> <resource-name> -n happylife`

For general Kubernetes questions, refer to the official documentation or community forums.
