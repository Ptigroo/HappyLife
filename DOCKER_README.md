# Docker Setup for HappyLife Application

This guide explains how to run the HappyLife application using Docker and Docker Compose.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop) installed
- [Docker Compose](https://docs.docker.com/compose/install/) (included with Docker Desktop)

## Quick Start

### 1. Set up environment variables

Copy the `.env.example` file to `.env`:

```bash
cp .env.example .env
```

Edit `.env` and add your Azure Document Intelligence API key:

```
AZURE_DOC_INTEL_API_KEY=your_actual_api_key_here
```

### 2. Build and run the application

```bash
docker-compose up -d
```

This will:
- Start a MySQL 8.0 database container
- Build and start the .NET 9 application container
- Create a network for the containers to communicate

### 3. Access the application

- **API**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger

### 4. View logs

```bash
# View all logs
docker-compose logs -f

# View only webapp logs
docker-compose logs -f webapp

# View only MySQL logs
docker-compose logs -f mysql
```

## Docker Commands

### Stop the application

```bash
docker-compose down
```

### Stop and remove all data (including database volumes)

```bash
docker-compose down -v
```

### Rebuild the application

```bash
docker-compose up -d --build
```

### View running containers

```bash
docker-compose ps
```

### Execute commands in containers

```bash
# Access webapp container shell
docker-compose exec webapp bash

# Access MySQL container
docker-compose exec mysql mysql -u root -p
```

## Configuration

### Database Connection

The application is configured to connect to the MySQL container using:
- **Host**: `mysql` (container name)
- **Port**: `3306`
- **Database**: `HappyLifeDb`
- **User**: `root`
- **Password**: `admin`

You can modify these values in `docker-compose.yml` if needed.

### Application Ports

- **Application**: Port `8080` (mapped to host port `8080`)
- **MySQL**: Port `3306` (mapped to host port `3306`)

To change the application port, modify the `ports` section in `docker-compose.yml`:

```yaml
ports:
  - "YOUR_PORT:8080"  # Change YOUR_PORT to desired port
```

### Environment Variables

Key environment variables in `docker-compose.yml`:

- `ASPNETCORE_ENVIRONMENT`: Set to `Development` or `Production`
- `ConnectionStrings__DefaultConnection`: MySQL connection string
- `AzureDocumentIntelligence__Endpoint`: Azure service endpoint
- `AzureDocumentIntelligence__ApiKey`: Azure API key (set in `.env` file)

## Production Considerations

For production deployment:

1. **Change default passwords**: Update MySQL passwords in `docker-compose.yml`
2. **Use secrets management**: Consider using Docker secrets or external secret management
3. **Enable HTTPS**: Configure SSL certificates
4. **Persistent storage**: Ensure MySQL volume is backed up regularly
5. **Resource limits**: Add resource constraints to prevent container overuse
6. **Health checks**: Monitor container health and implement restart policies
7. **Logging**: Configure centralized logging for production monitoring

Example production resource limits:

```yaml
webapp:
  # ... other configuration
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 2G
      reservations:
        cpus: '1'
        memory: 1G
```

## Troubleshooting

### Application won't start

1. Check logs: `docker-compose logs webapp`
2. Ensure MySQL is healthy: `docker-compose ps`
3. Verify environment variables are set correctly

### Database connection errors

1. Wait for MySQL to be fully ready (health check takes ~30 seconds)
2. Check MySQL logs: `docker-compose logs mysql`
3. Verify connection string in `docker-compose.yml`

### Port conflicts

If port `8080` or `3306` is already in use:
1. Stop the conflicting service
2. Or modify the port mapping in `docker-compose.yml`

### Rebuild from scratch

```bash
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

## Development Workflow

For development with hot reload:

1. Mount source code as volumes in `docker-compose.yml`
2. Use `docker-compose watch` (Docker Compose v2.22+)
3. Or run the app locally and only MySQL in Docker

## Support

For issues or questions, please refer to the main README.md or create an issue in the repository.
