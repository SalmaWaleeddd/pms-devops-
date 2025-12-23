# PMS Testing Team - Deployment Guide

**Version:** 1.0
**Last Updated:** December 22, 2025
**Prepared by:** DevOps Team

---

## 🎯 What This Guide Is For

This guide helps you deploy the complete PMS application on your local machine for testing. Everything runs in Docker containers - you don't need to install .NET, Node.js, SQL Server, or Kafka separately.

---

## 📋 Prerequisites

Before you start, make sure you have:

### Required:
- ✅ **Docker Desktop** installed and running
  - Windows: [Download Docker Desktop](https://www.docker.com/products/docker-desktop)
  - Mac: [Download Docker Desktop](https://www.docker.com/products/docker-desktop)
  - Linux: Install Docker Engine + Docker Compose

- ✅ **Minimum System Requirements:**
  - 8GB RAM (16GB recommended)
  - 20GB free disk space
  - Stable internet connection (first-time only)

### Check if Docker is ready:
```bash
docker --version
docker-compose --version
docker info
```

All commands should work without errors.

---

## 🚀 Quick Start (5 Minutes)

### Step 1: Get the Files

Download these 2 files from DevOps team:
1. `docker-compose.testing.yml`
2. `deploy-testing.sh`

Put them in a folder, for example:
```
C:\PMS-Testing\
  ├── docker-compose.testing.yml
  └── deploy-testing.sh
```

### Step 2: Deploy Everything

**Windows (PowerShell):**
```powershell
cd C:\PMS-Testing
bash deploy-testing.sh
```

**Mac/Linux:**
```bash
cd ~/PMS-Testing
./deploy-testing.sh
```

### Step 3: Wait for Startup (~2 minutes)

The script will:
1. Pull images from Docker Hub (slow first time)
2. Start all services
3. Run health checks
4. Show you access URLs

### Step 4: Access Applications

After deployment completes:
- **Admin Frontend:** http://localhost:4200
- **Parker Frontend:** http://localhost:4201
- **Backend APIs:** http://localhost:5001, 5002, 5003

---

## 📦 What Gets Deployed

When you run the deployment, you get:

### Frontend Applications:
- **Admin Frontend** (port 4200) - Administrative interface
- **Parker Frontend** (port 4201) - Parking user interface

### Backend Microservices:
- **Booking Service** (port 5001) - Handles bookings
- **Invoice Service** (port 5002) - Manages invoices
- **Site Service** (port 5003) - Manages parking sites

### Infrastructure:
- **SQL Server** (port 1433) - Database with 3 separate databases
- **Kafka** (port 9092/29092) - Message broker for microservices
- **Zookeeper** (port 2181) - Kafka coordination

**Total: 8 containers** running together

---

## 🔧 Common Tasks

### 1. View Logs

**All services:**
```bash
docker-compose -f docker-compose.testing.yml logs -f
```

**Specific service:**
```bash
docker-compose -f docker-compose.testing.yml logs -f booking-service
docker-compose -f docker-compose.testing.yml logs -f admin-frontend
```

Press `Ctrl+C` to stop viewing logs.

### 2. Check Service Status

```bash
docker-compose -f docker-compose.testing.yml ps
```

You should see all services with "Up" status.

### 3. Restart a Service

**Restart one service:**
```bash
docker-compose -f docker-compose.testing.yml restart booking-service
```

**Restart all services:**
```bash
docker-compose -f docker-compose.testing.yml restart
```

### 4. Stop Everything

```bash
docker-compose -f docker-compose.testing.yml down
```

This stops and removes containers but **keeps data** (databases, volumes).

### 5. Update to Latest Version

When developers push new code, Jenkins builds new images. To get the latest:

```bash
# Pull latest images
docker-compose -f docker-compose.testing.yml pull

# Restart with new images
docker-compose -f docker-compose.testing.yml up -d
```

Or just run the deploy script again:
```bash
./deploy-testing.sh
```

### 6. Complete Reset (Clean Slate)

⚠️ **Warning:** This deletes ALL data including database records!

```bash
# Stop everything and remove volumes
docker-compose -f docker-compose.testing.yml down -v

# Start fresh
./deploy-testing.sh
```

---

## 🐛 Troubleshooting

### Problem: "Docker is not running"

**Solution:**
1. Open Docker Desktop
2. Wait for it to fully start (whale icon should be steady)
3. Try again

---

### Problem: Port already in use (e.g., "port 4200 already allocated")

**Solution:**
```bash
# Find what's using the port
netstat -ano | findstr :4200  # Windows
lsof -i :4200                  # Mac/Linux

# Stop the conflicting service or change port in docker-compose.testing.yml
```

---

### Problem: Services show as "unhealthy" or "starting"

**Solution:**
- Wait 2-3 minutes - services take time to start
- Check logs: `docker-compose -f docker-compose.testing.yml logs [service-name]`
- If still failing after 5 minutes, run: `./deploy-testing.sh` again

---

### Problem: "Cannot connect to the Docker daemon"

**Solution:**
- Make sure Docker Desktop is running
- On Windows, run PowerShell as Administrator
- On Linux, add your user to docker group: `sudo usermod -aG docker $USER`

---

### Problem: Frontend shows error "Cannot connect to backend"

**Solution:**
1. Check if backend services are running:
   ```bash
   curl http://localhost:5001/health
   curl http://localhost:5002/health
   curl http://localhost:5003/health
   ```
2. Check backend logs:
   ```bash
   docker-compose -f docker-compose.testing.yml logs booking-service
   ```

---

### Problem: Slow performance / containers crashing

**Solution:**
- Increase Docker Desktop memory allocation
  - Docker Desktop → Settings → Resources → Memory
  - Set to at least 8GB
- Close other heavy applications

---

## 📊 Understanding the Architecture

```
┌─────────────────────────────────────────────┐
│         YOUR BROWSER                        │
│  http://localhost:4200 (Admin)              │
│  http://localhost:4201 (Parker)             │
└────────────┬────────────────────────────────┘
             │
             ↓
┌─────────────────────────────────────────────┐
│       FRONTEND CONTAINERS                   │
│  ├─ Admin Frontend (Port 4200)              │
│  └─ Parker Frontend (Port 4201)             │
└────────────┬────────────────────────────────┘
             │
             ↓ API Calls
┌─────────────────────────────────────────────┐
│       BACKEND MICROSERVICES                 │
│  ├─ Booking Service (Port 5001)             │
│  ├─ Invoice Service (Port 5002)             │
│  └─ Site Service (Port 5003)                │
└────────┬───────────────────────┬────────────┘
         │                       │
         ↓                       ↓
┌─────────────────┐    ┌─────────────────┐
│   SQL SERVER    │    │     KAFKA       │
│  (Port 1433)    │    │  (Port 9092)    │
│                 │    │                 │
│  3 Databases:   │    │  Message        │
│  - PMS_Booking  │    │  Broker for     │
│  - PMS_Invoice  │    │  service        │
│  - PMS_Site     │    │  communication  │
└─────────────────┘    └─────────────────┘
```

---

## 🔐 Default Credentials

### SQL Server:
- **Username:** `sa`
- **Password:** `YourStrong@Passw0rd`
- **Databases:** `PMS_Booking`, `PMS_Invoice`, `PMS_Site`

**To connect with SQL client:**
```
Server: localhost,1433
User: sa
Password: YourStrong@Passw0rd
Trust Server Certificate: Yes
```

---

## 📝 Daily Testing Workflow

### Morning - Start Testing:
```bash
# Start everything
./deploy-testing.sh

# Wait for healthy status
docker-compose -f docker-compose.testing.yml ps
```

### During Day - Test & Report:
- Test features at http://localhost:4200 and http://localhost:4201
- If you find bugs, check logs to gather details
- Report issues to development team with log excerpts

### End of Day - Stop to Save Resources:
```bash
# Stop all services (data is preserved)
docker-compose -f docker-compose.testing.yml down
```

### When Developers Release Updates:
```bash
# Pull and restart with latest code
./deploy-testing.sh
```

---

## 🆘 Getting Help

### Check Service Health:
```bash
# See all container status
docker-compose -f docker-compose.testing.yml ps

# Check specific service logs
docker-compose -f docker-compose.testing.yml logs --tail=50 [service-name]
```

### Useful Commands Cheat Sheet:

| Task | Command |
|------|---------|
| Start everything | `./deploy-testing.sh` |
| Stop everything | `docker-compose -f docker-compose.testing.yml down` |
| View all logs | `docker-compose -f docker-compose.testing.yml logs -f` |
| Restart service | `docker-compose -f docker-compose.testing.yml restart booking-service` |
| Check status | `docker-compose -f docker-compose.testing.yml ps` |
| Update images | `docker-compose -f docker-compose.testing.yml pull` |
| Complete reset | `docker-compose -f docker-compose.testing.yml down -v` |

---

## 💡 Tips & Best Practices

### 1. Save Resources
Stop containers when not testing - they use RAM and CPU even when idle.

### 2. Update Regularly
Run `./deploy-testing.sh` at least once a day to get latest code.

### 3. Check Logs First
Before reporting bugs, check service logs - they often show the root cause.

### 4. Clean Up Periodically
Docker can use a lot of disk space over time:
```bash
# Remove unused images and containers (safe - won't touch your data)
docker system prune -a
```

### 5. Know Your Ports
If you need to test multiple versions, you can change ports in `docker-compose.testing.yml`:
```yaml
ports:
  - "4210:80"  # Changed from 4200 to 4210
```

---

## 📞 Support Contacts

**DevOps Team:** [your-email@company.com]
**Development Team:** [dev-email@company.com]

**Before contacting support, please collect:**
1. Output of: `docker-compose -f docker-compose.testing.yml ps`
2. Logs: `docker-compose -f docker-compose.testing.yml logs [service-name]`
3. Docker version: `docker --version`
4. Your OS and RAM

---

## ✅ Testing Checklist

Before reporting "environment is ready":

- [ ] All services show "Up" and "healthy"
- [ ] Admin frontend loads at http://localhost:4200
- [ ] Parker frontend loads at http://localhost:4201
- [ ] Backend APIs respond to health checks
- [ ] Can view logs for all services
- [ ] Know how to restart/update services

---

**Happy Testing!** 🚀

If you have suggestions to improve this guide, please share with DevOps team.
