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

echo "==========================================="
echo "  PMS Backend - Starting All Services"
echo "==========================================="
echo ""

cd /home/amal/devops_project/testing

# Step 1: Start all services
echo -e "${YELLOW}[1/4] Starting docker-compose services...${NC}"
docker-compose -f docker-compose.testing.yml up -d
echo -e "${GREEN}Done!${NC}"
echo ""

# Step 2: Wait for Kafka to be ready
echo -e "${YELLOW}[2/4] Waiting for Kafka to be ready...${NC}"
for i in {1..30}; do
    if docker exec pms-kafka kafka-topics --list --bootstrap-server localhost:9092 &>/dev/null; then
        echo -e "${GREEN}Kafka is ready!${NC}"
        break
    fi
    echo "  Waiting... ($i/30)"
    sleep 2
done
echo ""

# Step 3: Create Kafka topics
echo -e "${YELLOW}[3/4] Creating Kafka topics...${NC}"
docker exec pms-kafka kafka-topics --create --topic site-created --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092 2>/dev/null || echo "  topic site-created exists"
docker exec pms-kafka kafka-topics --create --topic booking-created --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092 2>/dev/null || echo "  topic booking-created exists"
docker exec pms-kafka kafka-topics --create --topic invoice-created --partitions 3 --replication-factor 1 --bootstrap-server localhost:9092 2>/dev/null || echo "  topic invoice-created exists"
echo -e "${GREEN}Done!${NC}"
echo ""

# Step 4: Restart backend services to connect to Kafka
echo -e "${YELLOW}[4/5] Restarting backend services...${NC}"
docker restart pms-booking-service pms-invoice-service pms-site-service
echo "  Waiting 10 seconds for services to initialize..."
sleep 10
echo -e "${GREEN}Done!${NC}"
echo ""

# Step 5: Start Kafka UI
echo -e "${YELLOW}[5/5] Starting Kafka UI...${NC}"
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
docker ps --format "table {{.Names}}\t{{.Status}}" | grep pms
echo ""

echo "API Health Check:"
echo -n "  Booking (5001): "
curl -s http://localhost:5001/api/booking > /dev/null && echo -e "${GREEN}OK${NC}" || echo -e "${RED}FAILED${NC}"
echo -n "  Invoice (5002): "
curl -s http://localhost:5002/api/invoice > /dev/null && echo -e "${GREEN}OK${NC}" || echo -e "${RED}FAILED${NC}"
echo -n "  Site (5003):    "
curl -s http://localhost:5003/api/site > /dev/null && echo -e "${GREEN}OK${NC}" || echo -e "${RED}FAILED${NC}"
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
