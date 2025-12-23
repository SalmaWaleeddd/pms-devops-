#!/bin/bash

# PMS Database Initialization Script
# This script runs Entity Framework migrations for all services

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=================================================="
echo "  PMS Database Migration & Initialization"
echo "=================================================="
echo ""

# Set proper .NET paths
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$HOME/.dotnet:$HOME/.dotnet/tools

# Check if backend repo exists
if [ ! -d "/home/amal/pms-backend" ]; then
    echo -e "${RED}Backend repository not found at /home/amal/pms-backend${NC}"
    echo "Please clone it first: git clone https://github.com/GS-PMS/pms-backend.git /home/amal/pms-backend"
    exit 1
fi

cd /home/amal/pms-backend

# Check if .NET SDK is installed
if ! command -v dotnet &> /dev/null; then
    echo -e "${RED}.NET SDK is not installed${NC}"
    echo "Installing .NET SDK..."

    # Install .NET SDK on Ubuntu/WSL
    wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
    chmod +x dotnet-install.sh
    ./dotnet-install.sh --channel 8.0
    rm dotnet-install.sh

    # Add to PATH permanently
    export DOTNET_ROOT=$HOME/.dotnet
    export PATH=$PATH:$HOME/.dotnet:$HOME/.dotnet/tools
    echo 'export DOTNET_ROOT=$HOME/.dotnet' >> ~/.bashrc
    echo 'export PATH=$PATH:$HOME/.dotnet:$HOME/.dotnet/tools' >> ~/.bashrc
else
    echo -e "${GREEN}.NET SDK found: $(dotnet --version)${NC}"
fi

# Check if EF tools are installed
echo -e "${BLUE}Installing/Updating EF Core tools...${NC}"
dotnet tool install --global dotnet-ef --version 8.0.11 2>/dev/null || dotnet tool update --global dotnet-ef --version 8.0.11 2>/dev/null || echo "EF tools already installed"

# Connection string
DB_PASSWORD="YourStrong@Passw0rd"

echo ""
echo -e "${BLUE}Running database migrations...${NC}"
echo ""

# Site Service Migration
echo -e "${YELLOW}1/3 Migrating Site Service database...${NC}"
dotnet ef database update \
    --project Site.Infrastrcure.Persistent \
    --startup-project Site.API \
    --connection "Server=localhost;Database=PMS_Site;User Id=sa;Password=${DB_PASSWORD};TrustServerCertificate=True;" \
    2>&1 | grep -E "Applying|Done|already|Error" || echo -e "${GREEN}Done.${NC}"

echo ""

# Booking Service Migration
echo -e "${YELLOW}2/3 Migrating Booking Service database...${NC}"
dotnet ef database update \
    --project Booking.Infrastrcure.Persistent \
    --startup-project Booking.API \
    --connection "Server=localhost;Database=PMS_Booking;User Id=sa;Password=${DB_PASSWORD};TrustServerCertificate=True;" \
    2>&1 | grep -E "Applying|Done|already|Error" || echo -e "${GREEN}Done.${NC}"

echo ""

# Invoice Service Migration
echo -e "${YELLOW}3/3 Migrating Invoice Service database...${NC}"
dotnet ef database update \
    --project Invoice.Infrastrcure.Persistent \
    --startup-project Invoice.API \
    --connection "Server=localhost;Database=PMS_Invoice;User Id=sa;Password=${DB_PASSWORD};TrustServerCertificate=True;" \
    2>&1 | grep -E "Applying|Done|already|Error" || echo -e "${GREEN}Done.${NC}"

echo ""
echo "=================================================="
echo -e "${GREEN}Database initialization complete!${NC}"
echo "=================================================="
echo ""
echo "You can now:"
echo "  1. Restart backend services: docker-compose -f docker-compose.testing.yml restart booking-service invoice-service site-service"
echo "  2. Check health: ./health-check.sh"
echo "  3. Access frontend: http://localhost:4200"
