# HappyLife Project Structure

Complete overview of the HappyLife project after Kubernetes migration.

## ?? Directory Structure

```
HappyLife/
?
??? ?? HappyLife/                          # Main web application project
?   ??? Controllers/
?   ?   ??? ConsumableController.cs        # API endpoints
?   ?   ??? Dtos/
?   ??? Program.cs                         # Application entry point (with health checks)
?   ??? HappyLife.csproj                   # Project file
?   ??? appsettings.json                   # Application settings
?
??? ?? HappyLifeModels/                    # Domain models
?   ??? Consumable.cs
?   ??? HappyLifeDbContext.cs
?   ??? AzureDocumentIntelligenceOptions.cs
?   ??? HappyLifeModels.csproj
?
??? ?? HappyLifeInterfaces/                # Interface definitions
?   ??? RepositoryInterfaces/
?   ??? ServiceInterfaces/
?
??? ?? HappyLifeRepository/                # Data access layer
?   ??? ConsumableRepository.cs
?   ??? HappyLifeRepository.csproj
?
??? ?? HappyLifeServices/                  # Business logic
?   ??? InvoiceToConsumableService.cs
?   ??? HappyLifeServices.csproj
?
??? ?? k8s/                                # ? Kubernetes manifests
?   ??? namespace.yaml                     # Namespace definition
?   ??? mysql-secret.yaml                  # MySQL credentials
?   ??? app-secret.yaml                    # Application secrets
?   ??? app-configmap.yaml                 # Application configuration
?   ??? mysql-pvc.yaml                     # MySQL persistent volume claim
?   ??? mysql-deployment.yaml              # MySQL deployment
?   ??? mysql-service.yaml                 # MySQL service (ClusterIP)
?   ??? webapp-deployment.yaml             # Webapp deployment (2 replicas)
?   ??? webapp-service.yaml                # Webapp service (NodePort)
?   ??? ingress.yaml                       # Optional ingress configuration
?   ??? kustomization.yaml                 # Kustomize configuration
?
??? ?? Dockerfile                          # Docker image definition
??? ?? docker-compose.yml                  # Docker Compose configuration
??? ?? .dockerignore                       # Docker ignore patterns
??? ?? .env.example                        # Environment variables template
??? ?? .gitignore                          # Git ignore patterns (updated)
?
??? ?? deploy-minikube.sh                  # ? Deployment script (Linux/Mac)
??? ?? deploy-minikube.ps1                 # ? Deployment script (Windows)
??? ?? cleanup-minikube.sh                 # ? Cleanup script (Linux/Mac)
??? ?? cleanup-minikube.ps1                # ? Cleanup script (Windows)
??? ?? Makefile                            # ? Make commands (Linux/Mac)
?
??? ?? DEPLOYMENT_GUIDE.md                 # ? Quick deployment guide
??? ?? DOCKER_README.md                    # Docker Compose documentation
??? ?? KUBERNETES_README.md                # ? Kubernetes documentation
??? ?? DOCKER_VS_KUBERNETES.md             # ? Comparison guide
??? ?? MIGRATION_SUMMARY.md                # ? Migration summary
??? ?? KUBERNETES_QUICK_REFERENCE.md       # ? Quick reference card
??? ?? PROJECT_STRUCTURE.md                # ? This file
?
??? ?? HappyLife.sln                       # Solution file

? = New files added during Kubernetes migration
```

## ?? File Descriptions

### Application Code

#### `HappyLife/Program.cs`
Main application entry point with:
- Health checks configuration (`/health` endpoint)
- Database health check implementation
- Service registration
- Middleware configuration

#### `HappyLife/Controllers/ConsumableController.cs`
API endpoints:
- `POST /Consumable/upload-bill` - Upload and process invoice
- `POST /Consumable/initialize-from-invoice` - Initialize consumables
- `GET /Consumable/all` - Get all consumables

### Docker Configuration

#### `Dockerfile`
Multi-stage build:
1. **Build stage**: Restore dependencies and build
2. **Publish stage**: Publish the application
3. **Runtime stage**: Create lightweight runtime image

#### `docker-compose.yml`
Defines two services:
- **mysql**: MySQL 8.0 database with health checks
- **webapp**: .NET 9 application

#### `.env.example`
Template for environment variables:
- Azure Document Intelligence credentials
- MySQL configuration

### Kubernetes Configuration

#### `k8s/namespace.yaml`
Creates `happylife` namespace for resource isolation.

#### `k8s/mysql-secret.yaml`
Contains MySQL credentials:
- Root password
- Database name
- User credentials

#### `k8s/app-secret.yaml`
Contains application secrets:
- Azure Document Intelligence API key

#### `k8s/app-configmap.yaml`
Non-sensitive configuration:
- ASPNETCORE_ENVIRONMENT
- Connection string template
- Azure endpoint URL

#### `k8s/mysql-pvc.yaml`
Persistent storage for MySQL:
- 5Gi storage request
- ReadWriteOnce access mode

#### `k8s/mysql-deployment.yaml`
MySQL deployment with:
- 1 replica (stateful)
- Health checks (liveness and readiness)
- Resource limits
- Volume mounts

#### `k8s/mysql-service.yaml`
ClusterIP service for internal MySQL access.

#### `k8s/webapp-deployment.yaml`
Application deployment with:
- 2 replicas (high availability)
- Health checks via `/health` endpoint
- Init container (wait for MySQL)
- Resource limits
- Environment variables from ConfigMap and Secret

#### `k8s/webapp-service.yaml`
NodePort service:
- Exposes application on port 30080
- Load balances between replicas

#### `k8s/ingress.yaml`
Optional ingress configuration:
- Domain-based routing
- Can use with Minikube ingress addon

#### `k8s/kustomization.yaml`
Kustomize configuration:
- Lists all resources
- Applies common labels
- Enables `kubectl apply -k k8s/`

### Deployment Scripts

#### `deploy-minikube.sh` (Linux/Mac)
Automated deployment:
- Checks/starts Minikube
- Configures Docker environment
- Builds Docker image
- Validates API key configuration
- Deploys all Kubernetes resources
- Waits for pods to be ready
- Displays access information

#### `deploy-minikube.ps1` (Windows)
PowerShell version of deployment script with same functionality.

#### `cleanup-minikube.sh` (Linux/Mac)
Cleanup script:
- Confirms deletion
- Removes namespace and all resources

#### `cleanup-minikube.ps1` (Windows)
PowerShell version of cleanup script.

#### `Makefile`
Convenient make commands:
- `make all`: Complete deployment
- `make build`: Build Docker image
- `make deploy`: Deploy to Kubernetes
- `make status`: View status
- `make logs`: View logs
- `make scale`: Scale application
- `make clean`: Clean up
- And many more...

### Documentation

#### `DEPLOYMENT_GUIDE.md`
Quick start guide with:
- Both deployment options
- Quick comparison table
- Configuration instructions
- Common commands

#### `DOCKER_README.md`
Complete Docker Compose guide:
- Prerequisites
- Setup instructions
- Configuration
- Troubleshooting
- Production considerations

#### `KUBERNETES_README.md`
Complete Kubernetes guide:
- Prerequisites and setup
- Architecture explanation
- Step-by-step deployment
- Common operations
- Troubleshooting
- Production considerations

#### `DOCKER_VS_KUBERNETES.md`
Detailed comparison:
- Feature comparison tables
- Architecture diagrams
- Use cases
- Migration path
- Cost considerations

#### `MIGRATION_SUMMARY.md`
Summary of migration:
- What was done
- Key features gained
- Files modified
- Learning outcomes
- Future enhancements

#### `KUBERNETES_QUICK_REFERENCE.md`
Quick reference card:
- Essential commands
- Common operations
- Troubleshooting steps
- Pro tips

#### `PROJECT_STRUCTURE.md`
This file - complete project overview.

## ?? Key Features

### High Availability
- **2 webapp replicas** for load balancing
- **Automatic failover** if a pod crashes
- **Health checks** for monitoring

### Configuration Management
- **Secrets** for sensitive data
- **ConfigMaps** for configuration
- **Environment-specific** settings

### Storage
- **Persistent volumes** for MySQL data
- **Automatic provisioning** in Minikube
- **Data survives pod restarts**

### Networking
- **DNS-based service discovery**
- **Load balancing** built-in
- **NodePort** for external access
- **ClusterIP** for internal communication

### Monitoring
- **Health endpoints** (`/health`)
- **Liveness probes** (restart if unhealthy)
- **Readiness probes** (remove from service if not ready)

## ?? Deployment Workflows

### Docker Compose Workflow
```
1. Configure .env file
2. docker-compose up -d
3. Access at localhost:8080
4. docker-compose logs -f (view logs)
5. docker-compose down (stop)
```

### Kubernetes Workflow (Script)
```
1. Edit k8s/app-secret.yaml (API key)
2. ./deploy-minikube.sh (or .ps1 on Windows)
3. Access via URL shown by script
4. kubectl logs -n happylife -l app=webapp -f (logs)
5. ./cleanup-minikube.sh (cleanup)
```

### Kubernetes Workflow (Manual)
```
1. minikube start --cpus=4 --memory=8192
2. eval $(minikube docker-env)
3. docker build -t happylife-webapp:latest .
4. Edit k8s/app-secret.yaml (API key)
5. kubectl apply -k k8s/
6. minikube service webapp-service -n happylife
7. kubectl delete namespace happylife (cleanup)
```

### Kubernetes Workflow (Makefile)
```
1. Edit k8s/app-secret.yaml (API key)
2. make all (complete deployment)
3. make status (check status)
4. make logs (view logs)
5. make clean (cleanup)
```

## ?? Resource Overview

### Docker Compose Resources
- **Containers**: 2 (mysql, webapp)
- **Networks**: 1 (happylife-network)
- **Volumes**: 1 (mysql-data)

### Kubernetes Resources
- **Namespace**: 1 (happylife)
- **Deployments**: 2 (mysql, webapp)
- **Services**: 2 (mysql-service, webapp-service)
- **ConfigMaps**: 1 (app-config)
- **Secrets**: 2 (mysql-secret, app-secret)
- **PersistentVolumeClaims**: 1 (mysql-pvc)
- **Pods**: 3 (1 mysql + 2 webapp)

## ?? Endpoints

### Application Endpoints

#### Docker Compose
- **API**: http://localhost:8080
- **Swagger**: http://localhost:8080/swagger
- **Health**: http://localhost:8080/health

#### Kubernetes
- **API**: http://$(minikube ip):30080
- **Swagger**: http://$(minikube ip):30080/swagger
- **Health**: http://$(minikube ip):30080/health

### API Endpoints
- `GET /health` - Health check
- `POST /Consumable/upload-bill` - Upload invoice
- `POST /Consumable/initialize-from-invoice` - Initialize consumables
- `GET /Consumable/all` - Get all consumables

## ?? Security Considerations

### Secrets Management
- **Development**: Secrets in files (k8s/*-secret.yaml)
- **Production**: Use external secret management (Azure Key Vault, HashiCorp Vault)

### API Key Protection
- Never commit real API keys to git
- Use `.env` file (gitignored) for Docker Compose
- Use external secret management for Kubernetes

### Database Credentials
- Default credentials should be changed for production
- Use strong passwords
- Restrict network access

## ?? Scalability

### Docker Compose
- Limited to single host
- Manual scaling: `docker-compose up -d --scale webapp=3`
- No load balancing

### Kubernetes
- Can scale across multiple nodes
- Easy scaling: `kubectl scale deployment webapp --replicas=10`
- Built-in load balancing
- Can add Horizontal Pod Autoscaler

## ?? Learning Resources

### For Docker Compose
- Official docs: https://docs.docker.com/compose/

### For Kubernetes
- Official docs: https://kubernetes.io/docs/
- Minikube: https://minikube.sigs.k8s.io/docs/
- kubectl cheat sheet: https://kubernetes.io/docs/reference/kubectl/cheatsheet/

### For .NET Development
- ASP.NET Core: https://docs.microsoft.com/aspnet/core/
- Health checks: https://docs.microsoft.com/aspnet/core/host-and-deploy/health-checks

## ?? Next Steps

### After Initial Deployment
1. ? Test all API endpoints
2. ? Verify health checks
3. ? Check logs
4. ? Test scaling

### Advanced Features
1. ? Add monitoring (Prometheus, Grafana)
2. ? Implement ingress controller
3. ? Add autoscaling (HPA)
4. ? Configure CI/CD pipeline
5. ? Deploy to cloud (AKS, EKS, GKE)

## ?? Contributing

Both deployment methods are maintained. When contributing:
1. Test with Docker Compose (fast feedback)
2. Validate with Kubernetes (production-like)
3. Update relevant documentation
4. Ensure health checks pass

---

**This project structure supports both development (Docker Compose) and production-grade deployment (Kubernetes). Choose the right tool for your needs! ??**
