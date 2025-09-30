# Local Development with podman compose 

## Overview

Local development environments are crucial for developer productivity and application quality. Using podman compose , developers can create consistent, reproducible development environments that closely mirror production while remaining lightweight and fast to start. This guide demonstrates how to set up and manage local development environments for .NET and React Native applications using podman compose  with Red Hat UBI images.

podman compose  provides the same functionality as Docker Compose but with enhanced security through rootless containers, making it ideal for enterprise development environments where security is paramount.

## Key Concepts

### podman compose  Benefits

- **Rootless Containers**: Enhanced security without requiring root privileges
- **Development Consistency**: Same environment across all developer machines
- **Production Parity**: Mirror production architecture locally
- **Resource Efficiency**: Lightweight containers start quickly
- **Service Isolation**: Each service runs independently
- **Easy Debugging**: Individual service access and log monitoring

### Development vs Production

| Aspect | Development | Production |
|--------|-------------|------------|
| Volume Mounts | Source code hot reload | Built application artifacts |
| Environment Variables | Development settings | Production configuration |
| Networking | Direct port access | Load balancer/ingress |
| Persistence | Temporary volumes | Persistent storage |
| Monitoring | Basic logging | Full observability stack |
| Security | Simplified for debugging | Hardened security policies |

### Container Orchestration Patterns

- **Multi-service Applications**: Frontend, backend, and database coordination
- **Service Dependencies**: Proper startup ordering and health checks
- **Development Overrides**: Different configurations for local development
- **Hot Reloading**: Live code updates without container rebuilds
- **Database Management**: Consistent data seeding and migrations

## Prerequisites

- Podman and podman compose  installed and configured
- Understanding of containerization concepts
- Basic knowledge of YAML configuration
- Familiarity with .NET and React Native development
- Understanding of networking and service communication

### Installation Requirements

```bash
# Install Podman and podman compose 
# On RHEL/CentOS/Fedora
sudo dnf install podman podman-compose

# On macOS
brew install podman
pip3 install podman-compose

# Verify installation
podman --version
podman compose --version
```

## Practical Examples

### Example 1: Airline Booking Development Environment

Let's create a comprehensive development environment for an airline booking application with multiple services.

#### Step 1: Project Structure

```
airline-dev/
├── compose.yml
├── podman-compose.override.yml
├── .env
├── api/
│   ├── Containerfile.dev
│   ├── UserService/
│   ├── FlightService/
│   ├── BookingService/
│   └── PaymentService/
├── web/
│   ├── Containerfile.dev
│   └── src/
├── mobile/
│   ├── Containerfile.dev
│   └── src/
├── database/
│   ├── init-scripts/
│   └── seed-data/
└── infrastructure/
    ├── nginx/
    ├── monitoring/
    └── scripts/
```

#### Step 2: Main Compose Configuration

```yaml
# compose.yml
version: '3.8'

services:
  # Reverse Proxy and Load Balancer
  nginx:
    image: registry.access.redhat.com/ubi8/nginx-120
    container_name: airline-nginx
    ports:
      - "80:8080"
      - "443:8443"
    volumes:
      - ./infrastructure/nginx/nginx.conf:/etc/nginx/nginx.conf:Z
      - ./infrastructure/nginx/ssl:/etc/nginx/ssl:Z
    depends_on:
      - user-service
      - flight-service
      - booking-service
      - web-app
    networks:
      - app-network
    restart: unless-stopped

  # User Management Service
  user-service:
    build:
      context: ./api/UserService
      Containerfile: Containerfile.dev
    container_name: airline-user-service
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:8080
      - ConnectionStrings__DefaultConnection=Host=postgres;Database=userdb;Username=userservice;Password=${DB_PASSWORD}
      - JWT__SecretKey=${JWT_SECRET}
      - JWT__Issuer=ecommerce-dev
      - JWT__Audience=ecommerce-users
      - Redis__ConnectionString=redis:6379
      - Logging__LogLevel__Default=Information
      - Logging__LogLevel__Microsoft=Warning
    ports:
      - "5001:8080"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ./api/UserService:/app:Z
      - user-service-nuget:/root/.nuget/packages
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Flight Service
  flight-service:
    build:
      context: ./api/FlightService
      Containerfile: Containerfile.dev
    container_name: airline-flight-service
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:8080
      - ConnectionStrings__DefaultConnection=Host=postgres;Database=flightdb;Username=flightservice;Password=${DB_PASSWORD}
      - Redis__ConnectionString=redis:6379
      - EventBus__ConnectionString=amqp://guest:guest@rabbitmq:5672
      - Storage__ConnectionString=minio:9000
      - Storage__AccessKey=${MINIO_ACCESS_KEY}
      - Storage__SecretKey=${MINIO_SECRET_KEY}
    ports:
      - "5002:8080"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    volumes:
      - ./api/FlightService:/app:Z
      - flight-service-nuget:/root/.nuget/packages
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Booking Service
  booking-service:
    build:
      context: ./api/BookingService
      Containerfile: Containerfile.dev
    container_name: airline-booking-service
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:8080
      - ConnectionStrings__DefaultConnection=Host=postgres;Database=bookingdb;Username=bookingservice;Password=${DB_PASSWORD}
      - Services__UserService__BaseUrl=http://user-service:8080
      - Services__FlightService__BaseUrl=http://flight-service:8080
      - Services__PaymentService__BaseUrl=http://payment-service:8080
      - EventBus__ConnectionString=amqp://guest:guest@rabbitmq:5672
      - Redis__ConnectionString=redis:6379
    ports:
      - "5003:8080"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
      user-service:
        condition: service_healthy
      flight-service:
        condition: service_healthy
    volumes:
      - ./api/BookingService:/app:Z
      - booking-service-nuget:/root/.nuget/packages
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Payment Processing Service
  payment-service:
    build:
      context: ./api/PaymentService
      Containerfile: Containerfile.dev
    container_name: airline-payment-service
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:8080
      - ConnectionStrings__DefaultConnection=Host=postgres;Database=paymentdb;Username=paymentservice;Password=${DB_PASSWORD}
      - EventBus__ConnectionString=amqp://guest:guest@rabbitmq:5672
      - PaymentGateway__ApiKey=${PAYMENT_GATEWAY_API_KEY}
      - PaymentGateway__SecretKey=${PAYMENT_GATEWAY_SECRET_KEY}
      - PaymentGateway__Environment=sandbox
    ports:
      - "5004:8080"
    depends_on:
      postgres:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    volumes:
      - ./api/PaymentService:/app:Z
      - payment-service-nuget:/root/.nuget/packages
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Booking Web Application (React)
  web-app:
    build:
      context: ./web
      Containerfile: Containerfile.dev
    container_name: airline-web-app
    environment:
      - NODE_ENV=development
      - REACT_APP_API_BASE_URL=http://localhost/api
      - REACT_APP_WEBSOCKET_URL=ws://localhost/ws
      - CHOKIDAR_USEPOLLING=true
    ports:
      - "3000:3000"
    volumes:
      - ./web:/app:Z
      - web-app-node-modules:/app/node_modules
    networks:
      - app-network
    restart: unless-stopped
    stdin_open: true
    tty: true

  # PostgreSQL Database
  postgres:
    image: registry.access.redhat.com/rhel8/postgresql-13
    container_name: airline-postgres
    environment:
      - POSTGRESQL_USER=postgres
      - POSTGRESQL_PASSWORD=${DB_PASSWORD}
      - POSTGRESQL_DATABASE=postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/pgsql/data
      - ./database/init-scripts:/docker-entrypoint-initdb.d:Z
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis Cache
  redis:
    image: registry.access.redhat.com/rhel8/redis-6
    container_name: airline-redis
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/var/lib/redis/data
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

  # RabbitMQ Message Broker
  rabbitmq:
    image: registry.access.redhat.com/ubi8/ubi:latest
    container_name: airline-rabbitmq
    environment:
      - RABBITMQ_DEFAULT_USER=guest
      - RABBITMQ_DEFAULT_PASS=guest
      - RABBITMQ_DEFAULT_VHOST=/
    ports:
      - "5672:5672"
      - "15672:15672"
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
      - ./infrastructure/rabbitmq/rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf:Z
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: rabbitmq-diagnostics -q ping
      interval: 30s
      timeout: 10s
      retries: 5

  # MinIO Object Storage
  minio:
    image: quay.io/minio/minio:latest
    container_name: airline-minio
    command: server /data --console-address ":9001"
    environment:
      - MINIO_ROOT_USER=${MINIO_ACCESS_KEY}
      - MINIO_ROOT_PASSWORD=${MINIO_SECRET_KEY}
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data
    networks:
      - app-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3

volumes:
  postgres_data:
  redis_data:
  rabbitmq_data:
  minio_data:
  user-service-nuget:
  flight-service-nuget:
  booking-service-nuget:
  payment-service-nuget:
  web-app-node-modules:

networks:
  app-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

#### Step 3: Development Override Configuration

```yaml
# podman-compose.override.yml
version: '3.8'

services:
  user-service:
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - Logging__LogLevel__Default=Debug
      - Logging__LogLevel__Microsoft=Information
      - Development__EnableSensitiveDataLogging=true
    volumes:
      - ./api/UserService:/app:Z
      - user-service-nuget:/root/.nuget/packages
    command: >
      bash -c "
        dotnet restore &&
        dotnet watch run --urls http://+:8080
      "

  flight-service:
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - Logging__LogLevel__Default=Debug
      - Development__EnableSensitiveDataLogging=true
    volumes:
      - ./api/FlightService:/app:Z
      - flight-service-nuget:/root/.nuget/packages
    command: >
      bash -c "
        dotnet restore &&
        dotnet watch run --urls http://+:8080
      "

  booking-service:
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - Logging__LogLevel__Default=Debug
      - Development__EnableSensitiveDataLogging=true
    volumes:
      - ./api/BookingService:/app:Z
      - booking-service-nuget:/root/.nuget/packages
    command: >
      bash -c "
        dotnet restore &&
        dotnet watch run --urls http://+:8080
      "

  payment-service:
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - Logging__LogLevel__Default=Debug
      - Development__EnableSensitiveDataLogging=true
    volumes:
      - ./api/PaymentService:/app:Z
      - payment-service-nuget:/root/.nuget/packages
    command: >
      bash -c "
        dotnet restore &&
        dotnet watch run --urls http://+:8080
      "

  web-app:
    environment:
      - NODE_ENV=development
      - FAST_REFRESH=true
      - CHOKIDAR_USEPOLLING=true
      - WATCHPACK_POLLING=true
    command: npm start
    stdin_open: true
    tty: true

  # Development tools
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: ecommerce-pgadmin
    environment:
      - PGADMIN_DEFAULT_EMAIL=admin@example.com
      - PGADMIN_DEFAULT_PASSWORD=admin
    ports:
      - "5050:80"
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    networks:
      - app-network
    restart: unless-stopped

  redis-commander:
    image: rediscommander/redis-commander:latest
    container_name: ecommerce-redis-commander
    environment:
      - REDIS_HOSTS=local:redis:6379
      - REDIS_PASSWORD=${REDIS_PASSWORD}
    ports:
      - "8081:8081"
    networks:
      - app-network
    restart: unless-stopped

volumes:
  pgadmin_data:
```

#### Step 4: Environment Configuration

```bash
# .env
# Database Configuration
DB_PASSWORD=dev_password_123
POSTGRES_DB=ecommerce_dev

# Redis Configuration
REDIS_PASSWORD=redis_dev_password

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key_for_development_only

# MinIO Configuration
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin123

# Payment Gateway (Sandbox)
PAYMENT_GATEWAY_API_KEY=sandbox_api_key
PAYMENT_GATEWAY_SECRET_KEY=sandbox_secret_key

# Development Settings
ASPNETCORE_ENVIRONMENT=Development
NODE_ENV=development
```

#### Step 5: Development Containerfiles

**.NET Service Development Containerfile:**

```Containerfile
# api/UserService/Containerfile.dev
FROM registry.access.redhat.com/ubi8/dotnet-60

# Install development tools
USER root
RUN dnf update -y && \
    dnf install -y curl procps-ng && \
    dnf clean all

# Create app user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy project files
COPY --chown=appuser:appuser *.csproj ./
RUN dotnet restore

# Copy source code
COPY --chown=appuser:appuser . ./

# Switch to app user
USER appuser

# Expose port
EXPOSE 8080

# Install dotnet tools for hot reload
RUN dotnet tool install --global dotnet-ef
RUN dotnet tool install --global dotnet-watch
ENV PATH="$PATH:/home/appuser/.dotnet/tools"

# Default command for development (can be overridden)
CMD ["dotnet", "watch", "run", "--urls", "http://+:8080"]
```

**React Development Containerfile:**

```Containerfile
# web/Containerfile.dev
FROM registry.access.redhat.com/ubi8/nodejs-16

# Install development tools
USER root
RUN dnf update -y && \
    dnf install -y git curl && \
    dnf clean all

# Create app user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy package files
COPY --chown=appuser:appuser package*.json ./

# Switch to app user
USER appuser

# Install dependencies
RUN npm ci

# Copy source code
COPY --chown=appuser:appuser . ./

# Expose port
EXPOSE 3000

# Set environment for development
ENV NODE_ENV=development
ENV CHOKIDAR_USEPOLLING=true
ENV FAST_REFRESH=true

# Start development server
CMD ["npm", "start"]
```

### Example 2: React Native Development Environment

For React Native development, we need a specialized setup:

```yaml
# mobile-dev/compose.yml
version: '3.8'

services:
  # React Native Metro Bundler
  metro-bundler:
    build:
      context: .
      Containerfile: Containerfile.metro
    container_name: rn-metro-bundler
    environment:
      - NODE_ENV=development
      - REACT_NATIVE_PACKAGER_HOSTNAME=0.0.0.0
    ports:
      - "8081:8081"  # Metro bundler
      - "9090:9090"  # Flipper
    volumes:
      - ./src:/app/src:Z
      - ./assets:/app/assets:Z
      - rn-node-modules:/app/node_modules
    networks:
      - mobile-network
    restart: unless-stopped

  # Android Development Environment
  android-dev:
    build:
      context: .
      Containerfile: Containerfile.android
    container_name: rn-android-dev
    environment:
      - DISPLAY=${DISPLAY}
    volumes:
      - /tmp/.X11-unix:/tmp/.X11-unix:Z
      - ./:/app:Z
      - android-sdk:/opt/android-sdk
      - gradle-cache:/root/.gradle
    networks:
      - mobile-network
    privileged: true
    restart: unless-stopped

  # API Mock Server for Development
  mock-api:
    image: registry.access.redhat.com/ubi8/nodejs-16
    container_name: rn-mock-api
    working_dir: /app
    command: >
      bash -c "
        npm install -g json-server &&
        json-server --watch db.json --host 0.0.0.0 --port 3001
      "
    ports:
      - "3001:3001"
    volumes:
      - ./mock-data:/app:Z
    networks:
      - mobile-network
    restart: unless-stopped

volumes:
  rn-node-modules:
  android-sdk:
  gradle-cache:

networks:
  mobile-network:
    driver: bridge
```

### Example 3: Database Management and Seeding

```sql
-- database/init-scripts/01-create-databases.sql
-- Create separate databases for each service
CREATE DATABASE userdb;
CREATE DATABASE flightdb;
CREATE DATABASE bookingdb;
CREATE DATABASE paymentdb;

-- Create service users
CREATE USER userservice WITH ENCRYPTED PASSWORD 'dev_password_123';
CREATE USER flightservice WITH ENCRYPTED PASSWORD 'dev_password_123';
CREATE USER bookingservice WITH ENCRYPTED PASSWORD 'dev_password_123';
CREATE USER paymentservice WITH ENCRYPTED PASSWORD 'dev_password_123';

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE userdb TO userservice;
GRANT ALL PRIVILEGES ON DATABASE flightdb TO flightservice;
GRANT ALL PRIVILEGES ON DATABASE bookingdb TO bookingservice;
GRANT ALL PRIVILEGES ON DATABASE paymentdb TO paymentservice;
```

```sql
-- database/init-scripts/02-seed-data.sql
\c flightdb;

-- Sample flight data for development
INSERT INTO flights (id, flight_number, origin, destination, departure_time, arrival_time, base_fare, seats_available, created_at) VALUES
('11111111-1111-1111-1111-111111111111', 'AI101', 'SFO', 'JFK', NOW() + INTERVAL '1 day', NOW() + INTERVAL '1 day 5 hours', 299.99, 120, NOW()),
('33333333-3333-3333-3333-333333333333', 'AI202', 'LAX', 'ORD', NOW() + INTERVAL '2 days', NOW() + INTERVAL '2 days 4 hours', 199.99, 150, NOW()),
('55555555-5555-5555-5555-555555555555', 'AI303', 'SEA', 'BOS', NOW() + INTERVAL '3 days', NOW() + INTERVAL '3 days 5 hours', 249.99, 100, NOW());

\c userdb;

-- Sample user data for development
INSERT INTO users (id, email, first_name, last_name, password_hash, created_at) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'john.doe@example.com', 'John', 'Doe', '$2a$11$example_hash', NOW()),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'jane.smith@example.com', 'Jane', 'Smith', '$2a$11$example_hash', NOW());
```

## Common Pitfalls

### 1. Volume Mount Issues

**Problem**: File permission errors or changes not reflecting in containers.

**Solution**: Use proper SELinux contexts and understand rootless mapping:

```yaml
services:
  api:
    volumes:
      # Correct: Use :Z for SELinux relabeling
      - ./src:/app/src:Z
      # Incorrect: Missing SELinux context
      - ./src:/app/src
```

### 2. Service Startup Dependencies

**Problem**: Services starting before dependencies are ready.

**Solution**: Use proper health checks and depends_on conditions:

```yaml
services:
  api:
    depends_on:
      database:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### 3. Network Connectivity Issues

**Problem**: Services can't communicate or resolve each other's names.

**Solution**: Use explicit networks and proper service naming:

```yaml
networks:
  app-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16

services:
  api:
    networks:
      - app-network
    environment:
      - DATABASE_HOST=postgres  # Use service name for internal communication
```

### 4. Resource Consumption

**Problem**: Development environment consuming too many system resources.

**Solution**: Set resource limits and use efficient base images:

```yaml
services:
  api:
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
        reservations:
          memory: 256M
          cpus: '0.25'
```

## Best Practices

### 1. Environment Configuration

```yaml
# Use environment-specific overrides
# compose.yml - Base configuration
# podman-compose.override.yml - Development overrides
# podman-compose.prod.yml - Production configuration

services:
  api:
    environment:
      - ASPNETCORE_ENVIRONMENT=${ENVIRONMENT:-Development}
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
```

### 2. Development Scripts

Create helper scripts for common development tasks:

```bash
#!/bin/bash
# scripts/dev-start.sh

set -e

echo "🚀 Starting development environment..."

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Start services
podman compose up -d postgres redis rabbitmq

# Wait for databases to be ready
echo "⏳ Waiting for databases..."
sleep 10

# Run database migrations
echo "🔄 Running database migrations..."
podman compose exec user-service dotnet ef database update
podman compose exec product-service dotnet ef database update
podman compose exec order-service dotnet ef database update

# Start application services
echo "🔧 Starting application services..."
podman compose up -d

echo "✅ Development environment is ready!"
echo "🌐 Web app: http://localhost:3000"
echo "📊 API docs: http://localhost/swagger"
echo "🗄️  Database admin: http://localhost:5050"
echo "📦 Redis admin: http://localhost:8081"
```

```bash
#!/bin/bash
# scripts/dev-stop.sh

echo "🛑 Stopping development environment..."
podman compose down

echo "🧹 Cleaning up..."
podman system prune -f --volumes

echo "✅ Development environment stopped!"
```

### 3. Hot Reloading Configuration

```csharp
// Program.cs for .NET services
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.UseSwagger();
    app.UseSwaggerUI();
    
    // Enable detailed errors for development
    app.UseDeveloperExceptionPage();
    
    // Enable CORS for local development
    app.UseCors(builder => builder
        .AllowAnyOrigin()
        .AllowAnyMethod()
        .AllowAnyHeader());
}
```

### 4. Logging and Debugging

```yaml
services:
  api:
    environment:
      - Logging__LogLevel__Default=Debug
      - Logging__LogLevel__Microsoft=Information
      - Logging__Console__IncludeScopes=true
    volumes:
      - ./logs:/app/logs:Z
```

### 5. Security in Development

```yaml
# Use secrets for sensitive data even in development
secrets:
  db_password:
    file: ./secrets/db_password.txt
  jwt_secret:
    file: ./secrets/jwt_secret.txt

services:
  api:
    secrets:
      - db_password
      - jwt_secret
    environment:
      - ConnectionStrings__DefaultConnection=Host=postgres;Database=mydb;Username=user;Password_File=/run/secrets/db_password
```

## Tools and Resources

### Development Tools

- **Podman Desktop**: GUI for container management
- **Visual Studio Code**: With Podman and development container extensions
- **Postman**: API testing and documentation
- **pgAdmin**: PostgreSQL administration
- **Redis Commander**: Redis data browser

### Monitoring and Debugging

```yaml
# Add to podman-compose.override.yml for development monitoring
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus-dev.yml:/etc/prometheus/prometheus.yml:Z

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - ./monitoring/grafana/dashboards:/var/lib/grafana/dashboards:Z
```

### Useful Commands

```bash
# Start all services
podman compose up -d

# View logs for specific service
podman compose logs -f user-service

# Execute commands in running container
podman compose exec user-service bash

# Scale a service
podman compose up -d --scale product-service=2

# Rebuild and restart a service
podman compose up -d --build user-service

# Stop and remove all containers
podman compose down

# Remove volumes (careful with data loss)
podman compose down -v

# View resource usage
podman stats

# Clean up unused resources
podman system prune -f
```

## Hands-on Exercise

### Exercise: Complete Microservices Development Environment

Create a comprehensive development environment for a microservices-based application.

**Requirements:**

1. **Application Services:**
   - Authentication service (.NET)
   - Product catalog service (.NET)
   - Order management service (.NET)
   - Notification service (.NET)
   - Web frontend (React)
   - Mobile app development (React Native)

2. **Infrastructure Services:**
   - PostgreSQL database with multiple schemas
   - Redis for caching and sessions
   - RabbitMQ for event-driven communication
   - MinIO for file storage
   - Nginx as reverse proxy

3. **Development Features:**
   - Hot reloading for all services
   - Database seeding with test data
   - Automated database migrations
   - Health checks for all services
   - Centralized logging
   - Development monitoring dashboard

4. **Developer Experience:**
   - One-command startup and shutdown
   - Consistent environment across team
   - Easy debugging and testing
   - Documentation and helper scripts

**Deliverables:**

1. Complete podman compose  configuration
2. Development Containerfiles for each service
3. Database initialization and seeding scripts
4. Development helper scripts
5. Environment configuration management
6. Documentation for onboarding new developers
7. Performance optimization guide

**Evaluation Criteria:**

- Environment startup time (< 2 minutes)
- Resource efficiency (< 4GB RAM usage)
- Hot reload functionality
- Service communication reliability
- Documentation quality
- Developer onboarding experience

## Summary

Local development with podman compose  provides a powerful foundation for modern application development. Key takeaways include:

- **Consistent Environments**: podman compose  ensures all developers work with identical setups
- **Production Parity**: Local environments mirror production architecture and configuration
- **Enhanced Security**: Rootless containers provide better security isolation
- **Developer Productivity**: Hot reloading and automated setup reduce development friction
- **Service Orchestration**: Multi-service applications can be managed as cohesive units
- **Resource Efficiency**: Lightweight containers minimize system resource usage
- **Debugging Capabilities**: Individual service access and comprehensive logging aid troubleshooting

By implementing these practices with .NET and React Native applications using podman compose  and Red Hat UBI images, development teams can achieve faster development cycles, improved code quality, and seamless collaboration. The investment in setting up comprehensive development environments pays dividends in reduced debugging time, consistent behavior across environments, and faster onboarding of new team members.

