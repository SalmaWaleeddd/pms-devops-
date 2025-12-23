#!/bin/bash

echo "=================================================="
echo "  Initializing Kafka Topics for PMS"
echo "=================================================="

# Create required Kafka topics
echo ""
echo "Creating Kafka topics..."

docker exec pms-kafka kafka-topics --bootstrap-server localhost:9092 --create --topic site-created --partitions 3 --replication-factor 1 --if-not-exists
docker exec pms-kafka kafka-topics --bootstrap-server localhost:9092 --create --topic booking-created --partitions 3 --replication-factor 1 --if-not-exists
docker exec pms-kafka kafka-topics --bootstrap-server localhost:9092 --create --topic invoice-created --partitions 3 --replication-factor 1 --if-not-exists

echo ""
echo "Listing all topics:"
docker exec pms-kafka kafka-topics --bootstrap-server localhost:9092 --list

echo ""
echo "=================================================="
echo "Kafka topics initialized successfully!"
echo "=================================================="
echo ""
echo "Next step: Restart backend services"
echo "  docker-compose -f docker-compose.testing.yml restart booking-service invoice-service site-service"
