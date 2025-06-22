#!/bin/bash

# SFTPGo Backup Script
# Creates comprehensive backups of the entire SFTPGo installation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Change to project directory
cd "$(dirname "$0")/.."

# Configuration
BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/sftpgo_backup_$DATE.tar.gz"
RETENTION_DAYS=7

create_backup() {
    print_info "Starting backup process..."
    
    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"
    
    # Create temporary directory for backup preparation
    TEMP_DIR=$(mktemp -d)
    BACKUP_TEMP="$TEMP_DIR/sftpgo_backup_$DATE"
    mkdir -p "$BACKUP_TEMP"
    
    print_info "Preparing backup data..."
    
    # Stop services for consistent backup
    print_info "Stopping services for consistent backup..."
    docker-compose stop sftpgo
    
    # Copy configuration files
    print_info "Backing up configuration..."
    cp -r config "$BACKUP_TEMP/"
    
    # Copy user data
    print_info "Backing up user data..."
    if [ -d "data" ]; then
        cp -r data "$BACKUP_TEMP/"
    fi
    
    # Copy database
    print_info "Backing up database..."
    if [ -d "database" ]; then
        cp -r database "$BACKUP_TEMP/"
    fi
    
    # Copy logs (last 7 days only)
    print_info "Backing up recent logs..."
    if [ -d "logs" ]; then
        mkdir -p "$BACKUP_TEMP/logs"
        find logs/ -name "*.log*" -mtime -7 -exec cp {} "$BACKUP_TEMP/logs/" \; 2>/dev/null || true
    fi
    
    # Copy environment and docker-compose files
    print_info "Backing up deployment configuration..."
    cp .env "$BACKUP_TEMP/" 2>/dev/null || true
    cp docker-compose.yml "$BACKUP_TEMP/"
    cp README.md "$BACKUP_TEMP/" 2>/dev/null || true
    
    # Create backup metadata
    cat > "$BACKUP_TEMP/backup_info.txt" << EOF
SFTPGo Backup Information
========================
Backup Date: $(date)
Backup Version: $DATE
Hostname: $(hostname)
Docker Compose Version: $(docker-compose version --short 2>/dev/null || echo "Unknown")
SFTPGo Container Image: $(docker inspect sftpgo-server --format='{{.Config.Image}}' 2>/dev/null || echo "Not available")

Backup Contents:
- Configuration files (config/)
- User data (data/)
- Database files (database/)
- Recent logs (logs/ - last 7 days)
- Environment configuration (.env)
- Docker Compose configuration (docker-compose.yml)
- Documentation (README.md)

Restore Instructions:
1. Extract this backup to a new directory
2. Run: docker-compose down (if services are running)
3. Copy extracted files to SFTPGo installation directory
4. Run: docker-compose up -d
5. Verify services are running correctly
EOF
    
    # Create the compressed backup
    print_info "Creating compressed backup archive..."
    cd "$TEMP_DIR"
    tar -czf "$BACKUP_FILE" "sftpgo_backup_$DATE"
    cd - > /dev/null
    
    # Clean up temporary directory
    rm -rf "$TEMP_DIR"
    
    # Restart services
    print_info "Restarting services..."
    docker-compose start sftpgo
    
    # Wait for services to be ready
    sleep 10
    
    print_success "Backup created successfully: $BACKUP_FILE"
    
    # Show backup size
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    print_info "Backup size: $BACKUP_SIZE"
    
    # Clean old backups
    cleanup_old_backups
}

cleanup_old_backups() {
    print_info "Cleaning up old backups (keeping last $RETENTION_DAYS days)..."
    
    if [ -d "$BACKUP_DIR" ]; then
        # Find and delete backups older than retention period
        DELETED_COUNT=$(find "$BACKUP_DIR" -name "sftpgo_backup_*.tar.gz" -mtime +$RETENTION_DAYS -delete -print | wc -l)
        
        if [ "$DELETED_COUNT" -gt 0 ]; then
            print_info "Deleted $DELETED_COUNT old backup(s)"
        else
            print_info "No old backups to clean up"
        fi
    fi
}

list_backups() {
    print_info "Available backups:"
    echo ""
    
    if [ -d "$BACKUP_DIR" ] && [ "$(ls -A $BACKUP_DIR/*.tar.gz 2>/dev/null)" ]; then
        ls -lah "$BACKUP_DIR"/sftpgo_backup_*.tar.gz | while read -r line; do
            echo "  $line"
        done
    else
        print_warning "No backups found in $BACKUP_DIR"
    fi
    echo ""
}

verify_backup() {
    if [ -z "$1" ]; then
        print_error "Please specify backup file to verify"
        echo "Usage: $0 verify <backup_file>"
        exit 1
    fi
    
    BACKUP_TO_VERIFY="$1"
    
    if [ ! -f "$BACKUP_TO_VERIFY" ]; then
        print_error "Backup file not found: $BACKUP_TO_VERIFY"
        exit 1
    fi
    
    print_info "Verifying backup: $BACKUP_TO_VERIFY"
    
    # Test if the archive is valid
    if tar -tzf "$BACKUP_TO_VERIFY" > /dev/null 2>&1; then
        print_success "Backup archive is valid"
        
        # Show contents
        print_info "Backup contents:"
        tar -tzf "$BACKUP_TO_VERIFY" | head -20
        
        # Show backup info if available
        if tar -tzf "$BACKUP_TO_VERIFY" | grep -q "backup_info.txt"; then
            echo ""
            print_info "Backup information:"
            tar -xzf "$BACKUP_TO_VERIFY" -O "*/backup_info.txt" 2>/dev/null || print_warning "Could not extract backup info"
        fi
    else
        print_error "Backup archive is corrupted or invalid"
        exit 1
    fi
}

show_help() {
    echo "SFTPGo Backup Script"
    echo "===================="
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  backup          Create a new backup (default)"
    echo "  list            List all available backups"
    echo "  verify <file>   Verify backup integrity"
    echo "  cleanup         Clean up old backups only"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Create new backup"
    echo "  $0 backup                             # Create new backup"
    echo "  $0 list                               # List all backups"
    echo "  $0 verify backups/sftpgo_backup_20231218_143022.tar.gz"
    echo "  $0 cleanup                            # Clean old backups"
    echo ""
    echo "Configuration:"
    echo "  Backup location: $BACKUP_DIR"
    echo "  Retention period: $RETENTION_DAYS days"
    echo ""
}

# Main command processing
case "${1:-backup}" in
    backup)
        create_backup
        ;;
    list)
        list_backups
        ;;
    verify)
        verify_backup "$2"
        ;;
    cleanup)
        cleanup_old_backups
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
