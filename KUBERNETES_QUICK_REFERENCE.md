# HappyLife Kubernetes - Quick Reference Card

## ?? Quick Start

### Deploy to Minikube (Linux/Mac)
```bash
./deploy-minikube.sh
```

### Deploy to Minikube (Windows)
```powershell
.\deploy-minikube.ps1
```

### Using Makefile
```bash
make all          # Complete deployment
```

## ?? Essential Commands

### Deployment
```bash
# Deploy all resources
kubectl apply -k k8s/

# Deploy specific resource
kubectl apply -f k8s/webapp-deployment.yaml

# Delete all resources
kubectl delete namespace happylife
```

### Viewing Status
```bash
# All resources
kubectl get all -n happylife

# Pods only
kubectl get pods -n happylife

# Detailed pod info
kubectl get pods -n happylife -o wide

# Services
kubectl get svc -n happylife

# Watch changes
kubectl get pods -n happylife -w
```

### Logs
```bash
# Webapp logs (all replicas)
kubectl logs -n happylife -l app=webapp -f

# MySQL logs
kubectl logs -n happylife -l app=mysql -f

# Specific pod
kubectl logs -n happylife <pod-name> -f

# Previous logs (if crashed)
kubectl logs -n happylife <pod-name> --previous
```

### Debugging
```bash
# Describe pod (see events)
kubectl describe pod -n happylife <pod-name>

# Events
kubectl get events -n happylife --sort-by='.lastTimestamp'

# Shell access
kubectl exec -it -n happylife <pod-name> -- /bin/bash

# MySQL shell
kubectl exec -it -n happylife <mysql-pod> -- mysql -u root -padmin HappyLifeDb
```

### Scaling
```bash
# Scale manually
kubectl scale deployment webapp -n happylife --replicas=3

# View replicas
kubectl get deployment webapp -n happylife
```

### Updates
```bash
# Rolling update
kubectl set image deployment/webapp webapp=happylife-webapp:v2 -n happylife

# Restart deployment
kubectl rollout restart deployment webapp -n happylife

# Rollback
kubectl rollout undo deployment webapp -n happylife

# Rollout status
kubectl rollout status deployment webapp -n happylife
```

### Configuration
```bash
# Edit ConfigMap
kubectl edit configmap app-config -n happylife

# Edit Secret
kubectl edit secret app-secret -n happylife

# View ConfigMap
kubectl get configmap app-config -n happylife -o yaml

# View Secret (decoded)
kubectl get secret app-secret -n happylife -o jsonpath='{.data}'
```

## ?? Accessing the Application

### Get URL
```bash
# Get Minikube IP and port
minikube service webapp-service -n happylife --url

# Open in browser
minikube service webapp-service -n happylife
```

### Port Forward (Alternative)
```bash
# Forward to localhost:8080
kubectl port-forward -n happylife service/webapp-service 8080:8080
```

### Test Health Endpoint
```bash
curl http://$(minikube ip):30080/health
```

## ?? Minikube Commands

### Cluster Management
```bash
# Start Minikube
minikube start --cpus=4 --memory=8192

# Stop Minikube
minikube stop

# Delete cluster
minikube delete

# Status
minikube status

# Get IP
minikube ip
```

### Docker Environment
```bash
# Linux/Mac
eval $(minikube docker-env)

# Windows PowerShell
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

# Verify
docker ps
```

### Addons
```bash
# List addons
minikube addons list

# Enable ingress
minikube addons enable ingress

# Enable metrics-server
minikube addons enable metrics-server

# Dashboard
minikube dashboard
```

## ?? Update Application

### Rebuild and Deploy
```bash
# 1. Set Docker environment
eval $(minikube docker-env)

# 2. Rebuild image
docker build -t happylife-webapp:latest .

# 3. Restart pods
kubectl rollout restart deployment webapp -n happylife

# 4. Verify
kubectl rollout status deployment webapp -n happylife
```

### With Version Tags
```bash
# Build with version
docker build -t happylife-webapp:v1.0.1 .

# Update deployment
kubectl set image deployment/webapp webapp=happylife-webapp:v1.0.1 -n happylife

# Verify
kubectl rollout status deployment webapp -n happylife
```

## ??? Database Operations

### Backup
```bash
# Get MySQL pod name
MYSQL_POD=$(kubectl get pods -n happylife -l app=mysql -o jsonpath='{.items[0].metadata.name}')

# Backup database
kubectl exec -n happylife $MYSQL_POD -- mysqldump -u root -padmin HappyLifeDb > backup.sql
```

### Restore
```bash
# Restore from backup
kubectl exec -i -n happylife $MYSQL_POD -- mysql -u root -padmin HappyLifeDb < backup.sql
```

### Direct Access
```bash
# MySQL CLI
kubectl exec -it -n happylife $MYSQL_POD -- mysql -u root -padmin HappyLifeDb
```

## ?? Monitoring

### Resource Usage
```bash
# Pod resources (requires metrics-server)
kubectl top pods -n happylife

# Node resources
kubectl top nodes
```

### Health Checks
```bash
# Check health endpoint
kubectl exec -n happylife <webapp-pod> -- curl -s http://localhost:8080/health
```

## ?? Cleanup

### Delete Everything
```bash
# Delete namespace (removes all resources)
kubectl delete namespace happylife

# Or using script
./cleanup-minikube.sh     # Linux/Mac
.\cleanup-minikube.ps1    # Windows
```

### Clean Minikube
```bash
# Stop and delete
minikube stop
minikube delete

# Clean Docker images
docker rmi happylife-webapp:latest
```

## ?? File Locations

```
HappyLife/
??? k8s/                           # Kubernetes manifests
?   ??? namespace.yaml
?   ??? *-deployment.yaml
?   ??? *-service.yaml
?   ??? *-secret.yaml
?   ??? *-configmap.yaml
?   ??? kustomization.yaml
??? deploy-minikube.sh             # Deploy script (Linux/Mac)
??? deploy-minikube.ps1            # Deploy script (Windows)
??? cleanup-minikube.sh            # Cleanup script (Linux/Mac)
??? cleanup-minikube.ps1           # Cleanup script (Windows)
??? Makefile                       # Make commands
??? KUBERNETES_README.md           # Full K8s documentation
??? DOCKER_VS_KUBERNETES.md        # Comparison guide
??? DEPLOYMENT_GUIDE.md            # Quick start
```

## ?? Troubleshooting

### Pods Not Starting
```bash
# 1. Check status
kubectl get pods -n happylife

# 2. Describe pod
kubectl describe pod -n happylife <pod-name>

# 3. Check logs
kubectl logs -n happylife <pod-name>

# 4. Check events
kubectl get events -n happylife
```

### Image Pull Errors
```bash
# Ensure Docker environment is set
eval $(minikube docker-env)

# Verify image exists
docker images | grep happylife

# Rebuild if needed
docker build -t happylife-webapp:latest .
```

### Service Not Accessible
```bash
# Check service
kubectl get svc -n happylife

# Check endpoints
kubectl get endpoints -n happylife

# Test from pod
kubectl exec -n happylife <pod-name> -- curl -s http://mysql-service:3306
```

### MySQL Not Ready
```bash
# Check MySQL logs
kubectl logs -n happylife -l app=mysql

# Check PVC
kubectl get pvc -n happylife

# Describe pod for events
kubectl describe pod -n happylife <mysql-pod>
```

## ?? Useful Links

- **Kubernetes Docs**: https://kubernetes.io/docs/
- **Minikube Docs**: https://minikube.sigs.k8s.io/docs/
- **kubectl Cheat Sheet**: https://kubernetes.io/docs/reference/kubectl/cheatsheet/

## ?? Pro Tips

1. **Use aliases** for common commands:
   ```bash
   alias k='kubectl'
   alias kgp='kubectl get pods -n happylife'
   alias kl='kubectl logs -n happylife'
   ```

2. **Watch deployments**:
   ```bash
   watch kubectl get pods -n happylife
   ```

3. **Quick pod shell**:
   ```bash
   kubectl exec -it -n happylife $(kubectl get pods -n happylife -l app=webapp -o jsonpath='{.items[0].metadata.name}') -- /bin/bash
   ```

4. **View all configs**:
   ```bash
   kubectl get configmaps,secrets -n happylife
   ```

5. **Export resources**:
   ```bash
   kubectl get deployment webapp -n happylife -o yaml > webapp-backup.yaml
   ```

---

**Print this card and keep it handy! ??**
