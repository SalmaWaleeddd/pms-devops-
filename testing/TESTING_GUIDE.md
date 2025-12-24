# PMS Backend - Testing Guide

## Quick Start

### Start All Services
```bash

./start-all.sh
```

### Stop All Services
```bash
./stop-all.sh
```

---

## Access URLs

| Service | URL | Description |
|---------|-----|-------------|
| Admin Frontend | http://localhost:4200 | Manage parking sites |
| Parker Frontend | http://localhost:4201 | Customer booking portal |
| Kafka UI | http://localhost:8085 | Monitor Kafka messages |

---

## API Endpoints

| Service | URL |
|---------|-----|
| Booking API | http://localhost:5001/api/booking |
| Invoice API | http://localhost:5002/api/invoice |
| Site API | http://localhost:5003/api/site |

---

## Test Scenarios

### 1. Admin Frontend (http://localhost:4200)
- [ ] Create a new parking site
- [ ] Edit existing site
- [ ] Delete a site
- [ ] View all sites

### 2. Parker Frontend (http://localhost:4201)
- [ ] Select parking site from dropdown
- [ ] Fill reservation form
- [ ] Complete booking
- [ ] View invoice

### 3. Kafka Messages (http://localhost:8085)
- [ ] Check `site-created` topic when creating site
- [ ] Check `booking-created` topic when booking
- [ ] Check `invoice-created` topic after payment

---

## Verify Services Are Running

```bash
# Check all containers
docker ps | grep pms

# Test APIs
curl http://localhost:5001/api/booking
curl http://localhost:5003/api/site
```

---

## Troubleshooting

### Services not starting?
```bash
./stop-all.sh
./start-all.sh
```

### Database issues?
```bash
# Check SQL Server
docker logs pms-sqlserver
```

### Kafka issues?
```bash
# Check Kafka logs
docker logs pms-kafka

# List topics
docker exec pms-kafka kafka-topics --list --bootstrap-server localhost:9092
```

---

## Requirements
- Docker & Docker Compose installed
- Ports available: 4200, 4201, 5001-5003, 8085, 1433, 9092
