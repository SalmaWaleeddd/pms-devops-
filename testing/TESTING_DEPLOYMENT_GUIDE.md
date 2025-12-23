# PMS Testing Environment - Deployment Guide

**Version:** Build #7
**Date:** December 21, 2025
**Delivered by:** DevOps Team

---

## 📦 What's Included

This deployment package includes:
- ✅ **Backend Services**: 3 microservices (Booking, Invoice, Site)
- ✅ **Frontend Services**: 2 applications (Admin, Parker)
- ✅ **Infrastructure**: Kafka, Zookeeper, SQL Server
- ✅ **All services containerized** and ready to deploy

---

## 🚀 Quick Start (5 Minutes)

### Prerequisites
- Docker Desktop installed
- At least 8GB RAM available
- Ports available: 1433, 2181, 5001-5003, 4200-4201, 9092, 29092

### Deployment Steps

```bash
# 1. Create deployment directory
mkdir pms-testing
cd pms-testing

# 2. Download docker-compose file (see below)
# Save the docker-compose.yml from this guide

# 3. Start all services
docker-compose up -d

# 4. Wait for services to start (~2 minutes)
docker-compose ps

# 5. Access the applications
# Admin Frontend: http://localhost:4200
# Parker Frontend: http://localhost:4201
# Backend APIs: http://localhost:5001, 5002, 5003
```

---

## 📋 Complete Docker Compose File

Save this as `docker-compose.yml`:

```yaml
version: '3.8'

services:
  # Infrastructure Services

  zookeeper:
    image: confluentinc/cp-zookeeper:7.6.0
    container_name: pms-zookeeper
    ports:
      - "2181:2181"
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    networks:
      - pms-network
    healthcheck:
      test: ["CMD", "nc", "-z", "localhost", "2181"]
      interval: 10s
      timeout: 5s
      retries: 5

  kafka:
    image: confluentinc/cp-kafka:7.6.0
    container_name: pms-kafka
    depends_on:
      zookeeper:
        condition: service_healthy
    ports:
      - "9092:9092"
      - "29092:29092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092,PLAINTEXT_HOST://localhost:29092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: 'true'
    networks:
      - pms-network
    healthcheck:
      test: ["CMD", "kafka-broker-api-versions", "--bootstrap-server", "localhost:9092"]
      interval: 10s
      timeout: 10s
      retries: 5
      start_period: 15s

  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: pms-sqlserver
    ports:
      - "1433:1433"
    environment:
      ACCEPT_EULA: "Y"
      MSSQL_SA_PASSWORD: YourStrong@Passw0rd
      MSSQL_PID: Developer
    networks:
      - pms-network
    volumes:
      - sql_data:/var/opt/mssql
    healthcheck:
      test: /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -C -Q "SELECT 1" || exit 1
      interval: 15s
      timeout: 10s
      retries: 10
      start_period: 60s

  # Backend Microservices

  booking-service:
    image: amaleltelabany/pms-booking-service:latest
    container_name: pms-booking-service
    ports:
      - "5001:8080"
    environment:
      ASPNETCORE_ENVIRONMENT: Production
      ASPNETCORE_HTTP_PORTS: 8080
      Kafka__BootstrapServers: kafka:9092
      Kafka__ClientId: BookingService
      Kafka__Consumer__GroupId: BookingServiceGroup
      ConnectionStrings__DefaultConnection: "Server=sqlserver;Database=PMS_Booking;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;MultipleActiveResultSets=True;"
    depends_on:
      kafka:
        condition: service_healthy
      sqlserver:
        condition: service_healthy
    networks:
      - pms-network
    restart: unless-stopped

  invoice-service:
    image: amaleltelabany/pms-invoice-service:latest
    container_name: pms-invoice-service
    ports:
      - "5002:8080"
    environment:
      ASPNETCORE_ENVIRONMENT: Production
      ASPNETCORE_HTTP_PORTS: 8080
      Kafka__BootstrapServers: kafka:9092
      Kafka__ClientId: InvoiceService
      Kafka__Consumer__GroupId: InvoiceServiceGroup
      ConnectionStrings__DefaultConnection: "Server=sqlserver;Database=PMS_Invoice;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;MultipleActiveResultSets=True;"
    depends_on:
      kafka:
        condition: service_healthy
      sqlserver:
        condition: service_healthy
    networks:
      - pms-network
    restart: unless-stopped

  site-service:
    image: amaleltelabany/pms-site-service:latest
    container_name: pms-site-service
    ports:
      - "5003:8080"
    environment:
      ASPNETCORE_ENVIRONMENT: Production
      ASPNETCORE_HTTP_PORTS: 8080
      Kafka__BootstrapServers: kafka:9092
      Kafka__ClientId: SiteService
      Kafka__Consumer__GroupId: SiteServiceGroup
      ConnectionStrings__DefaultConnection: "Server=sqlserver;Database=PMS_Site;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;MultipleActiveResultSets=True;"
    depends_on:
      kafka:
        condition: service_healthy
      sqlserver:
        condition: service_healthy
    networks:
      - pms-network
    restart: unless-stopped

  # Frontend Applications

  admin-frontend:
    image: salmawaleedd/pms-admin-frontend:latest
    container_name: pms-admin-frontend
    ports:
      - "4200:80"
    environment:
      API_URL: http://localhost:5001
    depends_on:
      - booking-service
      - invoice-service
      - site-service
    networks:
      - pms-network
    restart: unless-stopped

  parker-frontend:
    image: salmawaleedd/pms-parker-frontend:latest
    container_name: pms-parker-frontend
    ports:
      - "4201:80"
    environment:
      API_URL: http://localhost:5001
    depends_on:
      - booking-service
      - invoice-service
      - site-service
    networks:
      - pms-network
    restart: unless-stopped

networks:
  pms-network:
    driver: bridge
    name: pms-network

volumes:
  sql_data:
    name: pms_sql_data
```

---

## 🌐 Access Points

Once deployed, access the services at:

| Service | URL | Purpose |
|---------|-----|---------|
| **Admin Frontend** | http://localhost:4200 | Admin dashboard |
| **Parker Frontend** | http://localhost:4201 | Parker application |
| **Booking API** | http://localhost:5001 | Booking microservice |
| **Invoice API** | http://localhost:5002 | Invoice microservice |
| **Site API** | http://localhost:5003 | Site management microservice |
| **SQL Server** | localhost:1433 | Database (sa / YourStrong@Passw0rd) |
| **Kafka** | localhost:29092 | Message broker (external access) |

---

## 🔍 Testing Commands

### Check Service Status
```bash
docker-compose ps
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f booking-service
docker-compose logs -f admin-frontend
```

### Restart a Service
```bash
docker-compose restart booking-service
```

### Stop All Services
```bash
docker-compose down
```

### Stop and Remove Data
```bash
docker-compose down -v
```

---

## 🧪 Health Checks

### Backend APIs
```bash
curl http://localhost:5001/health
curl http://localhost:5002/health
curl http://localhost:5003/health
```

### Database Connection
```bash
docker exec -it pms-sqlserver /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U sa -P 'YourStrong@Passw0rd' \
  -Q "SELECT name FROM sys.databases"
```

### Kafka Topics
```bash
docker exec pms-kafka kafka-topics --bootstrap-server localhost:9092 --list
```

---

## 📊 Service Architecture

```
┌─────────────────────────────────────────────┐
│           FRONTEND LAYER                    │
│  ┌──────────────┐    ┌──────────────┐      │
│  │ Admin UI     │    │ Parker UI    │      │
│  │ Port: 4200   │    │ Port: 4201   │      │
│  └──────┬───────┘    └──────┬───────┘      │
└─────────┼────────────────────┼──────────────┘
          │                    │
          └────────┬───────────┘
                   ↓
┌─────────────────────────────────────────────┐
│         BACKEND MICROSERVICES               │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐    │
│  │ Booking  │ │ Invoice  │ │   Site   │    │
│  │ :5001    │ │ :5002    │ │   :5003  │    │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘    │
└───────┼────────────┼────────────┼───────────┘
        │            │            │
        └────────┬───┴────┬───────┘
                 ↓        ↓
┌─────────────────────────────────────────────┐
│          INFRASTRUCTURE LAYER               │
│  ┌──────────┐              ┌──────────┐    │
│  │  Kafka   │←─Zookeeper──→│SQL Server│    │
│  │  :9092   │    :2181     │  :1433   │    │
│  └──────────┘              └──────────┘    │
└─────────────────────────────────────────────┘
```

---

## 🐛 Troubleshooting

### Services Won't Start
```bash
# Check for port conflicts
docker ps -a
netstat -an | grep -E "4200|4201|5001|5002|5003|1433|9092"

# Remove old containers
docker-compose down
docker-compose up -d
```

### Frontend Can't Connect to Backend
- Check backend is running: `docker-compose ps`
- Check backend health: `curl http://localhost:5001/health`
- Check browser console for CORS errors

### Database Connection Fails
- Wait 60 seconds for SQL Server to fully initialize
- Check health: `docker-compose ps sqlserver`
- Verify password: `YourStrong@Passw0rd`

---

## 📝 Test Scenarios

### Smoke Tests
1. ✅ All services start successfully
2. ✅ Frontend loads (4200, 4201)
3. ✅ Backend APIs respond (5001, 5002, 5003)
4. ✅ Database is accessible

### Functional Tests
1. Create a booking
2. Generate an invoice
3. Manage sites
4. Verify data persistence

### Integration Tests
1. Create booking → Verify invoice generated
2. Update site → Verify reflected across services
3. Check Kafka message flow

---

## 📞 Support

**Issues or Questions?**
- DevOps Team: [Your contact info]
- Documentation: This file
- CI/CD Pipeline: Jenkins at http://localhost:8080

---

## 🔄 Updating to Latest Version

```bash
# Pull latest images
docker-compose pull

# Restart services with new images
docker-compose up -d

# Verify update
docker-compose images
```

---

## 📅 Version History

| Build | Date | Changes |
|-------|------|---------|
| #7 | 2025-12-21 | Current testing build |
| #6 | 2025-12-21 | Backend services added |
| #4-5 | 2025-12-21 | Frontend services |

---

**Happy Testing!** 🎉
