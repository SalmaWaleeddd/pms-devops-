#!/bin/bash

# PMS Testing Environment Deployment Script
# This script deploys the complete PMS application stack for testing

set -e  # Exit on any error

echo "=================================================="
echo "  PMS Testing Environment Deployment"
echo "=================================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
COMPOSE_FILE="docker-compose.testing.yml"

# Function to print colored messages
print_success() {
    echo -e "${GREEN} $1${NC}"
}

print_warning() {
    echo -e "${YELLOW} $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Docker is running
echo " Checking Docker..."
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi
print_success "Docker is running"

# Check if docker-compose file exists
if [ ! -f "$COMPOSE_FILE" ]; then
    print_error "File $COMPOSE_FILE not found!"
    exit 1
fi

# Pull latest images from Docker Hub
echo ""
echo " Pulling latest images from Docker Hub..."
echo "   This may take a few minutes on first run..."
docker-compose -f $COMPOSE_FILE pull
print_success "Images pulled successfully"

# Stop existing containers if any
echo ""
echo " Stopping existing containers (if any)..."
docker-compose -f $COMPOSE_FILE down 2>/dev/null || true
print_success "Existing containers stopped"

# Start services
echo ""
echo " Starting PMS services..."
docker-compose -f $COMPOSE_FILE up -d

# Wait for services to be healthy
echo ""
echo " Waiting for services to be healthy (this takes ~60 seconds)..."
sleep 15
echo "   Infrastructure starting..."
sleep 15
echo "   Backend services starting..."
sleep 15
echo "   Frontend applications starting..."
sleep 15

# Check service status
echo ""
echo " Service Status:"
docker-compose -f $COMPOSE_FILE ps

# Health check
echo ""
echo " Performing health checks..."

# Function to check URL
check_url() {
    local url=$1
    local name=$2
    if curl -f -s -o /dev/null "$url" 2>/dev/null; then
        print_success "$name is healthy"
        return 0
    else
        print_warning "$name is not responding yet (may still be starting)"
        return 1
    fi
}

# Check backend services
check_url "http://localhost:5001/health" "Booking Service" || true
check_url "http://localhost:5002/health" "Invoice Service" || true
check_url "http://localhost:5003/health" "Site Service" || true

# Check frontend
check_url "http://localhost:4200" "Admin Frontend" || true
check_url "http://localhost:4201" "Parker Frontend" || true

# Display access information
echo ""
echo "=================================================="
echo "  PMS Testing Environment is Ready!"
echo "=================================================="
echo ""
echo " Access Points:"
echo "   Admin Frontend:    http://localhost:4200"
echo "   Parker Frontend:   http://localhost:4201"
echo ""
echo " Backend APIs:"
echo "   Booking Service:   http://localhost:5001"
echo "   Invoice Service:   http://localhost:5002"
echo "   Site Service:      http://localhost:5003"
echo ""
echo "  Infrastructure:"
echo "   SQL Server:        localhost:1433"
echo "   Kafka:             localhost:9092 (internal) / localhost:29092 (external)"
echo ""
echo " Useful Commands:"
echo "   View logs:         docker-compose -f $COMPOSE_FILE logs -f [service-name]"
echo "   Stop all:          docker-compose -f $COMPOSE_FILE down"
echo "   Restart service:   docker-compose -f $COMPOSE_FILE restart [service-name]"
echo "   Check status:      docker-compose -f $COMPOSE_FILE ps"
echo ""
echo " Note: If services show as 'not responding', wait 1-2 minutes for full startup"
echo "=================================================="
