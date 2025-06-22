# Quick Start Guide

## Prerequisites

- Docker installed and running
- Docker Compose installed
- Git (for cloning the repository)

## Installation

### 1. Clone Repository
```bash
git clone <repository-url>
cd sftpgo
```

### 2. Make Scripts Executable
```bash
chmod +x scripts/*.sh
```

### 3. Run Setup
```bash
./scripts/setup.sh
```

### 4. Access Services

**Web Admin Panel:**
- URL: http://localhost:8080
- Username: `admin`
- Password: `admin123`

**SFTP Server:**
- Host: `localhost`
- Port: `2022`

## Essential Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View status
./scripts/manage.sh status

# View logs
./scripts/manage.sh logs

# Create backup
./scripts/backup.sh

# Restart services
./scripts/manage.sh restart
```

## First Steps After Installation

1. **Change Admin Password**
   - Login to web admin
   - Go to Admins → Edit admin
   - Set strong password

2. **Create First SFTP User**
   - Go to Users → Add User
   - Set username and password
   - Configure permissions

3. **Test SFTP Connection**
   ```bash
   sftp -P 2022 username@localhost
   ```

## Need Help?

Read the complete [README.md](README.md) for detailed documentation.
