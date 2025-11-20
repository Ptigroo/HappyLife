# HappyLife - Quick Deployment Guide

This project supports **two deployment methods**: Docker Compose and Kubernetes. Choose the one that best fits your needs.

## ?? Quick Start

### Option 1: Docker Compose (Recommended for Development)

**Best for:** Local development, quick testing, learning Docker basics

```bash
# 1. Copy and configure environment variables
cp .env.example .env
# Edit .env and add your Azure API key

# 2. Start the application
docker-compose up -d

# 3. Access the application
# API: http://localhost:8080
# Swagger: http://localhost:8080/swagger
```

?? **Full Documentation:** [DOCKER_README.md](DOCKER_README.md)

---

### Option 2: Kubernetes with Minikube (Production-like)

**Best for:** Learning Kubernetes, production-like environment, advanced features

#### Linux/Mac:

```bash
# 1. Start Minikube
minikube start --cpus=4 --memory=8192

# 2. Configure Docker environment
eval $(minikube docker-env)

# 3. Build the image
docker build -t happylife-webapp:latest .

# 4. Update k8s/app-secret.yaml with your Azure API key

# 5. Deploy to Kubernetes
kubectl apply -k k8s/

# 6. Access the application
minikube service webapp-service -n happylife
```

#### Windows PowerShell:

```powershell
# 1. Start Minikube
minikube start --cpus=4 --memory=8192

# 2. Configure Docker environment
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

# 3. Build the image
docker build -t happylife-webapp:latest .

# 4. Update k8s/app-secret.yaml with your Azure API key

# 5. Deploy to Kubernetes
kubectl apply -k k8s/

# 6. Access the application
minikube service webapp-service -n happylife
```

#### Using Helper Scripts:

```bash
# Linux/Mac
chmod +x deploy-minikube.sh
./deploy-minikube.sh

# Windows
.\deploy-minikube.ps1
```

#### Using Makefile (Linux/Mac):

```bash
# Complete setup
make all

# Or step by step
make start-minikube
make build
make deploy
make status
```

?? **Full Documentation:** [KUBERNETES_README.md](KUBERNETES_README.md)

---

## ?? Comparison

| Feature | Docker Compose | Kubernetes |
|---------|---------------|------------|
| **Setup Time** | 5 minutes ? | 10-15 minutes |
| **Complexity** | Simple ? | Moderate |
| **Best For** | Development | Production-like |
| **Scaling** | Manual | Automatic |
| **High Availability** | ? | ? |
| **Learning Curve** | Easy | Moderate |

?? **Detailed Comparison:** [DOCKER_VS_KUBERNETES.md](DOCKER_VS_KUBERNETES.md)

---

## ?? Project Structure

```
HappyLife/
??? docker-compose.yml          # Docker Compose configuration
??? Dockerfile                  # Docker image definition
??? k8s/                        # Kubernetes manifests
?   ??? namespace.yaml
?   ??? mysql-*.yaml           # MySQL resources
?   ??? webapp-*.yaml          # Application resources
?   ??? *-secret.yaml          # Secrets
?   ??? *-configmap.yaml       # Configuration
?   ??? kustomization.yaml     # Kustomize config
??? deploy-minikube.sh         # Deployment script (Linux/Mac)
??? deploy-minikube.ps1        # Deployment script (Windows)
??? Makefile                   # Make commands (Linux/Mac)
??? DOCKER_README.md           # Docker Compose guide
??? KUBERNETES_README.md       # Kubernetes guide
??? DOCKER_VS_KUBERNETES.md    # Comparison guide
```

---

## ?? Prerequisites

### For Docker Compose:
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- Azure Document Intelligence API key

### For Kubernetes:
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Azure Document Intelligence API key

---

## ?? Configuration

Both deployment methods require an Azure Document Intelligence API key.

### Get Your API Key:
1. Go to [Azure Portal](https://portal.azure.com)
2. Create a Document Intelligence resource
3. Copy the API key from the resource

### Configure:

**Docker Compose:**
```bash
# In .env file
AZURE_DOC_INTEL_API_KEY=your_actual_api_key_here
```

**Kubernetes:**
```yaml
# In k8s/app-secret.yaml
stringData:
  AZURE_DOC_INTEL_API_KEY: "your_actual_api_key_here"
```

---

## ?? Recommended Approach

### For Learning / Development:
? **Start with Docker Compose** - It's faster and simpler

### For Production Skills:
? **Use Kubernetes** - Learn production-grade deployment

### For Production Deployment:
? **Use Kubernetes on a cloud provider** (AKS, EKS, GKE)

---

## ?? Useful Commands

### Docker Compose

```bash
# Start
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down

# Rebuild
docker-compose up -d --build
```

### Kubernetes

```bash
# Deploy
kubectl apply -k k8s/

# Status
kubectl get all -n happylife

# Logs
kubectl logs -n happylife -l app=webapp -f

# Scale
kubectl scale deployment webapp -n happylife --replicas=3

# Delete
kubectl delete namespace happylife
```

---

## ?? Documentation

- **[DOCKER_README.md](DOCKER_README.md)** - Complete Docker Compose guide
- **[KUBERNETES_README.md](KUBERNETES_README.md)** - Complete Kubernetes guide
- **[DOCKER_VS_KUBERNETES.md](DOCKER_VS_KUBERNETES.md)** - Detailed comparison

---

## ?? Troubleshooting

### Docker Compose Issues:
```bash
# Check logs
docker-compose logs

# Restart services
docker-compose restart

# Clean rebuild
docker-compose down -v
docker-compose up -d --build
```

### Kubernetes Issues:
```bash
# Check pod status
kubectl get pods -n happylife

# View pod logs
kubectl logs -n happylife <pod-name>

# Describe pod
kubectl describe pod -n happylife <pod-name>

# Check events
kubectl get events -n happylife
```

---

## ?? Architecture

### Application Components:
- **Web API** (.NET 9) - Main application
- **MySQL Database** (8.0) - Data persistence
- **Azure Document Intelligence** - Invoice processing

### Endpoints:
- `GET /health` - Health check (Kubernetes)
- `POST /Consumable/upload-bill` - Upload invoice
- `POST /Consumable/initialize-from-invoice` - Initialize from invoice
- `GET /Consumable/all` - Get all consumables

---

## ?? Contributing

Both deployment methods are maintained and tested. Feel free to:
1. Report issues
2. Submit improvements
3. Share your deployment experiences

---

## ?? License

This project deployment configuration is provided as-is for educational and development purposes.

---

## ?? Next Steps

### After Docker Compose:
1. ? Learn Kubernetes basics
2. ? Try Minikube deployment
3. ? Explore advanced K8s features

### After Kubernetes:
1. ? Deploy to cloud (AKS, EKS, GKE)
2. ? Add monitoring (Prometheus, Grafana)
3. ? Implement CI/CD
4. ? Configure ingress
5. ? Add autoscaling

---

**Choose your deployment method and get started! ??**
