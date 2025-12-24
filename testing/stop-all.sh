#!/bin/bash
#
# PMS Backend - Stop All Services
# Usage: ./stop-all.sh
#

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "==========================================="
echo "  PMS Backend - Stopping All Services"
echo "==========================================="
echo ""

cd /home/amal/devops_project/testing

# Stop extra containers (Kafka UI if running)
echo -e "${YELLOW}Stopping extra containers...${NC}"
docker rm -f kafka-ui 2>/dev/null || true

# Stop docker-compose services
echo -e "${YELLOW}Stopping all services...${NC}"
docker-compose -f docker-compose.testing.yml down

echo ""
echo "==========================================="
echo -e "${GREEN}  All Services Stopped!${NC}"
echo "==========================================="
echo ""
