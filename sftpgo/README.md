# SFTPGo Docker Deployment

A complete, production-ready SFTPGo server deployment using Docker Compose with separated database container for enterprise environments.

## 🚀 Quick Start

```bash
# Clone or download this repository
git clone <repository-url>
cd sftpgo

# Start the entire stack
./scripts/setup.sh

# Access web admin
open http://localhost:8080
```

**Default credentials:**
- Username: `admin`
- Password: `admin123`

⚠️ **Change default password immediately after first login!**

## 📋 Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   SFTPGo        │    │   SQLite        │
│   Container     │◄──►│   Container     │
│   Port: 8080    │    │   Database      │
│   Port: 2022    │    │                 │
└─────────────────┘    └─────────────────┘
         │                       │
         └───────────────────────┘
                   │
         ┌─────────────────┐
         │   Docker        │
         │   Volumes       │
         │   (Persistent)  │
         └─────────────────┘
```

## 🛠 Services

### SFTPGo Server
- **SFTP Server**: Port 2022
- **Web Admin**: Port 8080  
- **Web Client**: Port 8080
- **REST API**: Port 8080

### SQLite Database
- **Persistent Storage**: Dedicated container
- **Data Volume**: `/opt/sftpgo/database`
- **Backup Support**: Built-in

## 📁 Project Structure

```
sftpgo/
├── README.md                 # This documentation
├── docker-compose.yml        # Main Docker Compose configuration
├── .env                      # Environment variables
├── config/
│   └── sftpgo.json          # SFTPGo configuration
├── scripts/
│   ├── setup.sh             # One-click setup script
│   ├── manage.sh            # Management operations
│   ├── backup.sh            # Backup operations
│   └── restore.sh           # Restore operations
├── data/                    # User data (auto-created)
├── logs/                    # Application logs (auto-created)
├── backups/                 # Backup storage (auto-created)
└── database/                # SQLite database files (auto-created)
```

## 🔧 Management Commands

### Setup & Control
```bash
# Initial setup (run once)
./scripts/setup.sh

# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Restart services
docker-compose restart
```

### Service Management
```bash
# Show status
./scripts/manage.sh status

# Restart SFTPGo only
./scripts/manage.sh restart

# Update to latest version
./scripts/manage.sh update

# View real-time logs
./scripts/manage.sh logs
```

### Backup & Restore
```bash
# Create backup
./scripts/backup.sh

# List backups
ls -la backups/

# Restore from backup
./scripts/restore.sh backups/backup_20231218_143022.tar.gz
```

## 🌐 Access Information

### Web Administration
- **URL**: http://your-server-ip:8080
- **Default Username**: admin
- **Default Password**: admin123

### SFTP Access
- **Host**: your-server-ip
- **Port**: 2022
- **Protocol**: SFTP

Example SFTP connection:
```bash
sftp -P 2022 username@your-server-ip
```

## 👥 User Management

### Creating SFTP Users

1. Access web admin: http://your-server-ip:8080
2. Login with admin credentials
3. Navigate to **Users** → **Add User**
4. Configure user settings:
   - **Username**: Unique identifier
   - **Password**: Strong password
   - **Home Directory**: `/srv/sftpgo/data/username`
   - **Permissions**: Select appropriate access rights
   - **Quota**: Set storage limits (optional)

### User Permissions Options
- **List directories**
- **Download files** 
- **Upload files**
- **Overwrite files**
- **Delete files/directories**
- **Rename files/directories**
- **Create directories**
- **Create symlinks**
- **Change file/directory permissions**

## 🔒 Security Configuration

### Firewall Setup
```bash
# Allow SFTP
sudo ufw allow 2022/tcp

# Allow Web Admin (restrict by IP)
sudo ufw allow from YOUR_ADMIN_IP to any port 8080

# Enable firewall
sudo ufw enable
```

### SSL/TLS Setup (Optional)
Edit `config/sftpgo.json` to enable HTTPS:
```json
{
  "httpd": {
    "bindings": [
      {
        "port": 8080,
        "address": "0.0.0.0",
        "enable_https": true,
        "certificate_file": "/etc/ssl/sftpgo.crt",
        "certificate_key_file": "/etc/ssl/sftpgo.key"
      }
    ]
  }
}
```

## 📊 Monitoring & Logs

### Log Files
- **Application Logs**: `logs/sftpgo.log`
- **Container Logs**: `docker-compose logs sftpgo`
- **Database Logs**: `docker-compose logs sqlite`

### Health Monitoring
```bash
# Check container health
docker-compose ps

# Monitor resource usage
docker stats

# Test SFTP connectivity
./scripts/manage.sh test-sftp
```

## 💾 Backup Strategy

### Automated Backups
Set up automated backups with cron:
```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /path/to/sftpgo/scripts/backup.sh
```

### Backup Contents
- SQLite database
- User data files
- Configuration files
- Application logs

### Backup Retention
- **Local backups**: 7 days
- **Remote backups**: Configure external storage

## 🔄 Updates & Maintenance

### Updating SFTPGo
```bash
# Update to latest version
./scripts/manage.sh update

# Or manually
docker-compose pull
docker-compose up -d
```

### Maintenance Tasks
- **Regular backups**: Daily automated backups
- **Log rotation**: Automatic log management
- **Security updates**: Keep Docker images updated
- **Monitoring**: Regular health checks

## 🌍 External Access Setup

### Router Configuration
Forward these ports to your server:
- **Port 8080** → Server IP:8080 (Web Admin)
- **Port 2022** → Server IP:2022 (SFTP)

### Dynamic DNS (Optional)
For accessing via domain name:
```bash
# Example with DuckDNS
curl "https://www.duckdns.org/update?domains=yourdomain&token=yourtoken"
```

## ⚡ Performance Tuning

### Resource Limits
Edit `docker-compose.yml`:
```yaml
services:
  sftpgo:
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
```

### Database Optimization
For high-traffic environments, consider migrating to PostgreSQL:
```yaml
# Replace SQLite with PostgreSQL
  database:
    image: postgres:15
    environment:
      POSTGRES_DB: sftpgo
      POSTGRES_USER: sftpgo
      POSTGRES_PASSWORD: secure_password
```

## 🆘 Troubleshooting

### Common Issues

#### Container Won't Start
```bash
# Check Docker status
docker info

# Check logs
docker-compose logs

# Verify configuration
docker-compose config
```

#### Web Interface Not Accessible
```bash
# Check if port is bound
netstat -tln | grep 8080

# Verify container is running
docker-compose ps

# Check firewall
sudo ufw status
```

#### SFTP Connection Failed
```bash
# Test local connection
sftp -P 2022 username@localhost

# Check SFTP logs
docker-compose logs sftpgo | grep SFTP

# Verify user exists
# Login to web admin and check user configuration
```

#### Database Issues
```bash
# Check database container
docker-compose logs sqlite

# Verify database file permissions
ls -la database/

# Test database connection
docker-compose exec sqlite sqlite3 /database/sftpgo.db ".tables"
```

### Log Analysis
```bash
# Follow all logs
docker-compose logs -f

# Filter specific service
docker-compose logs -f sftpgo

# Search for errors
docker-compose logs | grep -i error
```

## 📚 Additional Resources

- **SFTPGo Documentation**: https://sftpgo.github.io/
- **Docker Compose Reference**: https://docs.docker.com/compose/
- **SFTP Client Setup**: https://sftpgo.github.io/latest/web-client/
- **API Documentation**: http://your-server:8080/openapi

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **SFTPGo Project**: https://github.com/drakkan/sftpgo
- **Docker**: For containerization platform
- **SQLite**: For embedded database solution

---

**Made with ❤️ for DevSecOps teams**
