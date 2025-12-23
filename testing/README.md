# PMS Testing Environment - Complete Package

This folder contains everything the testing team needs to deploy and test the Parking Management System (PMS) backend infrastructure.

## What's Included

### Deployment Files
- `docker-compose.testing.yml` - Complete Docker Compose configuration for all 8 services
- `deploy-testing.sh` - Automated deployment script
- `init-databases.sh` - Database initialization and migration script
- `init-kafka-topics.sh` - Kafka topics initialization script
- `seed-data.sql` - Sample test data for databases

### Testing & Monitoring
- `health-check.sh` - Comprehensive health check for all services
- `test-backend.sh` - Backend API testing script

### Documentation
- `TESTING_TEAM_GUIDE.md` - Complete guide for testing team (START HERE)
- `TESTING_DEPLOYMENT_GUIDE.md` - Detailed deployment instructions

## Quick Start

1. Read `TESTING_TEAM_GUIDE.md` first
2. Run `./deploy-testing.sh` to start all services
3. Run `./init-kafka-topics.sh` to create required Kafka topics
4. Restart backend: `docker-compose -f docker-compose.testing.yml restart booking-service invoice-service site-service`
5. Run `./health-check.sh` to verify everything is working
6. Run `./test-backend.sh` to test backend APIs

## System Requirements

- Docker installed and running
- Docker Compose installed
- At least 4GB RAM available
- Ports 5001, 5002, 5003, 1433, 9092, 2181, 4200, 4201 available

## Support

For issues or questions, contact:
- Amal Eltelbany (DevOps Engineer - Backend Infrastructure)
- Salma (DevOps Engineer - Frontend Infrastructure)

---


Date: December 23, 2025
