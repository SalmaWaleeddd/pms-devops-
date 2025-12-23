#!/bin/bash

# PMS Health Check Script
# Checks the health of all PMS services

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

COMPOSE_FILE="docker-compose.testing.yml"

echo "=================================================="
echo "  PMS Services Health Check"
echo "=================================================="
echo ""

# Function to check URL health
check_service() {
    local url=$1
    local name=$2
    local response_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")

    if [ "$response_code" -eq 200 ]; then
        echo -e "${GREEN}$name${NC} - Healthy (HTTP $response_code)"
        return 0
    elif [ "$response_code" -eq 000 ]; then
        echo -e "${RED}$name${NC} - Not responding"
        return 1
    else
        echo -e "${YELLOW}$name${NC} - Unhealthy (HTTP $response_code)"
        return 1
    fi
}

# Check Docker containers
echo -e "${BLUE}Docker Container Status:${NC}"
echo ""
docker-compose -f $COMPOSE_FILE ps
echo ""

# Check backend services
echo -e "${BLUE}Backend Services Health:${NC}"
check_service "http://localhost:5001/health" "Booking Service (Port 5001)"
check_service "http://localhost:5002/health" "Invoice Service (Port 5002)"
check_service "http://localhost:5003/health" "Site Service (Port 5003)"
echo ""

# Check frontend services
echo -e "${BLUE}Frontend Applications:${NC}"
check_service "http://localhost:4200" "Admin Frontend (Port 4200)"
check_service "http://localhost:4201" "Parker Frontend (Port 4201)"
echo ""

# Check infrastructure
echo -e "${BLUE}Infrastructure:${NC}"

# SQL Server check
if docker exec pms-sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "YourStrong@Passw0rd" -C -Q "SELECT 1" > /dev/null 2>&1; then
    echo -e "${GREEN}SQL Server (Port 1433)${NC} - Healthy"
else
    echo -e "${RED}SQL Server (Port 1433)${NC} - Not responding"
fi

# Kafka check
if docker exec pms-kafka kafka-broker-api-versions --bootstrap-server localhost:9092 > /dev/null 2>&1; then
    echo -e "${GREEN}Kafka (Port 9092)${NC} - Healthy"
else
    echo -e "${RED}Kafka (Port 9092)${NC} - Not responding"
fi

# Zookeeper check
if docker exec pms-zookeeper nc -z localhost 2181 > /dev/null 2>&1; then
    echo -e "${GREEN}Zookeeper (Port 2181)${NC} - Healthy"
else
    echo -e "${RED}Zookeeper (Port 2181)${NC} - Not responding"
fi

echo ""
echo "=================================================="
echo "  Health Check Complete"
echo "=================================================="
echo ""
echo "Tip: If services are unhealthy, check logs with:"
echo "  docker-compose -f $COMPOSE_FILE logs [service-name]"
