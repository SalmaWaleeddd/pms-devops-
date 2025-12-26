#!/bin/bash
#
# PMS Backend - Start All Services
# Usage: ./start-all.sh
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "==========================================="
echo "  PMS Backend - Starting All Services"
echo "==========================================="
echo ""

# Step 1: Start infrastructure only (SQL Server, Kafka, Zookeeper)
echo -e "${YELLOW}[1/6] Starting infrastructure services...${NC}"
docker-compose -f docker-compose.testing.yml up -d zookeeper sqlserver
sleep 5
docker-compose -f docker-compose.testing.yml up -d kafka
echo -e "${GREEN}Done!${NC}"
echo ""

# Step 2: Wait for Kafka to be ready
echo -e "${YELLOW}[2/6] Waiting for Kafka to be ready...${NC}"
for i in {1..30}; do
    if docker exec pms-kafka kafka-topics --list --bootstrap-server localhost:9092 &>/dev/null; then
        echo -e "${GREEN}Kafka is ready!${NC}"
        break
    fi
    echo "  Waiting... ($i/30)"
    sleep 2
done
echo ""

# Step 3: Create Kafka topics BEFORE starting backend services
echo -e "${YELLOW}[3/6] Creating Kafka topics...${NC}"
docker exec pms-kafka kafka-topics --create --topic site-created --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092 2>/dev/null || echo "  topic site-created exists"
docker exec pms-kafka kafka-topics --create --topic booking-created --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092 2>/dev/null || echo "  topic booking-created exists"
docker exec pms-kafka kafka-topics --create --topic ticket-created --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092 2>/dev/null || echo "  topic ticket-created exists"
docker exec pms-kafka kafka-topics --create --topic invoice-created --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092 2>/dev/null || echo "  topic invoice-created exists"
echo -e "${GREEN}Done!${NC}"
echo ""

# Step 4: Wait for SQL Server to be ready
echo -e "${YELLOW}[4/6] Waiting for SQL Server...${NC}"
for i in {1..30}; do
    if docker exec pms-sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -C -Q "SELECT 1" &>/dev/null; then
        echo "  SQL Server is ready!"
        break
    fi
    echo "  Waiting for SQL Server... ($i/30)"
    sleep 2
done

# Note: Database creation and migrations are handled by the backend services on startup
echo -e "${GREEN}SQL Server ready! (Databases will be created by backend services)${NC}"
echo ""

# Step 5: Start backend services and frontends
echo -e "${YELLOW}[5/6] Starting backend and frontend services...${NC}"
docker-compose -f docker-compose.testing.yml up -d
echo "  Waiting 15 seconds for services to initialize..."
sleep 15
echo -e "${GREEN}Done!${NC}"
echo ""

# Step 6: Start Kafka UI
echo -e "${YELLOW}[6/6] Starting Kafka UI...${NC}"
docker rm -f kafka-ui 2>/dev/null || true
docker run -d --name kafka-ui \
  --network testing_pms-network \
  -p 8085:8080 \
  -e KAFKA_CLUSTERS_0_NAME=pms-kafka \
  -e KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=kafka:9092 \
  provectuslabs/kafka-ui:latest
echo -e "${GREEN}Done!${NC}"
echo ""

# Verify services
echo "==========================================="
echo "  Verifying Services"
echo "==========================================="
echo ""

echo "Container Status:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "pms|kafka"
echo ""

echo "API Health Check:"
echo -n "  Booking (5001): "
curl -sf http://localhost:5001/api/booking > /dev/null && echo -e "${GREEN}OK${NC}" || echo -e "${RED}FAILED${NC}"
echo -n "  Invoice (5002): "
curl -sf http://localhost:5002/api/invoice > /dev/null && echo -e "${GREEN}OK${NC}" || echo -e "${RED}FAILED${NC}"
echo -n "  Site (5003):    "
curl -sf http://localhost:5003/api/site > /dev/null && echo -e "${GREEN}OK${NC}" || echo -e "${RED}FAILED${NC}"
echo ""

echo "==========================================="
echo -e "${GREEN}  All Services Started!${NC}"
echo "==========================================="
echo ""
echo "Access URLs:"
echo "  Admin Frontend:  http://localhost:4200"
echo "  Parker Frontend: http://localhost:4201"
echo "  Kafka UI:        http://localhost:8085"
echo ""
echo "API Endpoints:"
echo "  Booking API:     http://localhost:5001/api/booking"
echo "  Invoice API:     http://localhost:5002/api/invoice"
echo "  Site API:        http://localhost:5003/api/site"
echo ""
