#!/bin/bash

# SFTPGo Restore Script
# Restores SFTPGo installation from backup

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

restore_from_backup() {
    local BACKUP_FILE="$1"
    
    if [ -z "$BACKUP_FILE" ]; then
        print_error "Please specify backup file to restore from"
        echo "Usage: $0 <backup_file>"
        echo ""
        echo "Available backups:"
        ls -la backups/sftpgo_backup_*.tar.gz 2>/dev/null || echo "  No backups found"
        exit 1
    fi
    
    if [ ! -f "$BACKUP_FILE" ]; then
        print_error "Backup file not found: $BACKUP_FILE"
        exit 1
    fi
    
    # Verify backup integrity first
    print_info "Verifying backup integrity..."
    if ! tar -tzf "$BACKUP_FILE" > /dev/null 2>&1; then
        print_error "Backup file is corrupted or invalid"
        exit 1
    fi
    print_success "Backup file is valid"
    
    # Show backup information
    if tar -tzf "$BACKUP_FILE" | grep -q "backup_info.txt"; then
        echo ""
        print_info "Backup information:"
        tar -xzf "$BACKUP_FILE" -O "*/backup_info.txt" 2>/dev/null | head -15
        echo ""
    fi
    
    # Confirm restore operation
    echo ""
    print_warning "This will restore from: $BACKUP_FILE"
    print_warning "Current data will be backed up before restore"
    echo ""
    read -p "Do you want to continue? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Restore operation cancelled"
        exit 0
    fi
    
    # Create backup of current state
    CURRENT_BACKUP_DIR="./backups/pre_restore_$(date +%Y%m%d_%H%M%S)"
    print_info "Creating backup of current state..."
    mkdir -p "$CURRENT_BACKUP_DIR"
    
    # Backup current data
    [ -d "data" ] && cp -r data "$CURRENT_BACKUP_DIR/" 2>/dev/null || true
    [ -d "database" ] && cp -r database "$CURRENT_BACKUP_DIR/" 2>/dev/null || true
    [ -d "config" ] && cp -r config "$CURRENT_BACKUP_DIR/" 2>/dev/null || true
    [ -f ".env" ] && cp .env "$CURRENT_BACKUP_DIR/" 2>/dev/null || true
    
    print_success "Current state backed up to: $CURRENT_BACKUP_DIR"
    
    # Stop services
    print_info "Stopping services..."
    docker-compose down
    
    # Extract backup to temporary directory
    TEMP_DIR=$(mktemp -d)
    print_info "Extracting backup..."
    tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"
    
    # Find the backup directory (should be the only directory in temp)
    BACKUP_DATA_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "sftpgo_backup_*" | head -1)
    
    if [ -z "$BACKUP_DATA_DIR" ] || [ ! -d "$BACKUP_DATA_DIR" ]; then
        print_error "Could not find backup data in archive"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    print_info "Restoring files..."
    
    # Restore configuration
    if [ -d "$BACKUP_DATA_DIR/config" ]; then
        print_info "Restoring configuration files..."
        rm -rf config
        cp -r "$BACKUP_DATA_DIR/config" .
    fi
    
    # Restore data
    if [ -d "$BACKUP_DATA_DIR/data" ]; then
        print_info "Restoring user data..."
        rm -rf data
        cp -r "$BACKUP_DATA_DIR/data" .
    fi
    
    # Restore database
    if [ -d "$BACKUP_DATA_DIR/database" ]; then
        print_info "Restoring database..."
        rm -rf database
        cp -r "$BACKUP_DATA_DIR/database" .
    fi
    
    # Restore logs (optional)
    if [ -d "$BACKUP_DATA_DIR/logs" ]; then
        print_info "Restoring logs..."
        mkdir -p logs
        cp -r "$BACKUP_DATA_DIR/logs"/* logs/ 2>/dev/null || true
    fi
    
    # Restore environment file
    if [ -f "$BACKUP_DATA_DIR/.env" ]; then
        print_info "Restoring environment configuration..."
        cp "$BACKUP_DATA_DIR/.env" .
    fi
    
    # Restore docker-compose if it's different
    if [ -f "$BACKUP_DATA_DIR/docker-compose.yml" ]; then
        if ! diff -q docker-compose.yml "$BACKUP_DATA_DIR/docker-compose.yml" > /dev/null 2>&1; then
            print_warning "Docker Compose configuration differs from backup"
            read -p "Restore docker-compose.yml from backup? (y/N): " -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                cp "$BACKUP_DATA_DIR/docker-compose.yml" .
                print_info "Docker Compose configuration restored"
            fi
        fi
    fi
    
    # Set proper permissions
    print_info "Setting proper permissions..."
    chmod -R 755 data logs database 2>/dev/null || true
    mkdir -p data/users logs backups database
    
    # Clean up temporary directory
    rm -rf "$TEMP_DIR"
    
    # Start services
    print_info "Starting services..."
    docker-compose up -d
    
    # Wait for services to be ready
    print_info "Waiting for services to initialize..."
    sleep 15
    
    # Verify services are running
    if docker-compose ps | grep -q "Up"; then
        print_success "Services started successfully"
        
        # Test connectivity
        sleep 5
        if curl -s -f http://localhost:8080/healthz > /dev/null 2>&1; then
            print_success "Web interface is responding"
        else
            print_warning "Web interface may need more time to initialize"
        fi
    else
        print_error "Some services failed to start"
        docker-compose logs
    fi
    
    print_success "Restore completed successfully!"
    
    echo ""
    print_info "Post-restore checklist:"
    echo "  1. Verify web admin access: http://localhost:8080"
    echo "  2. Test SFTP connectivity"
    echo "  3. Check user accounts and permissions"
    echo "  4. Review configuration settings"
    echo ""
    print_info "Current state backup saved at: $CURRENT_BACKUP_DIR"
}

list_backups() {
    print_info "Available backups for restore:"
    echo ""
    
    if [ -d "backups" ] && [ "$(ls -A backups/sftpgo_backup_*.tar.gz 2>/dev/null)" ]; then
        ls -lah backups/sftpgo_backup_*.tar.gz | while read -r line; do
            echo "  $line"
        done
    else
        print_warning "No backups found in backups/ directory"
    fi
    echo ""
    
    if [ -d "backups" ] && [ "$(ls -A backups/pre_restore_* 2>/dev/null)" ]; then
        echo ""
        print_info "Pre-restore backups (current state backups):"
        ls -lah backups/pre_restore_* | while read -r line; do
            echo "  $line"
        done
        echo ""
    fi
}

show_help() {
    echo "SFTPGo Restore Script"
    echo "===================="
    echo ""
    echo "Usage: $0 <backup_file>"
    echo "   or: $0 list"
    echo ""
    echo "Commands:"
    echo "  <backup_file>   Restore from specified backup file"
    echo "  list            List all available backups"
    echo "  help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 backups/sftpgo_backup_20231218_143022.tar.gz"
    echo "  $0 list"
    echo ""
    echo "Notes:"
    echo "  - Current data will be automatically backed up before restore"
    echo "  - Services will be restarted during the restore process"
    echo "  - Restore process will verify backup integrity first"
    echo ""
}

# Main command processing
case "${1:-help}" in
    list)
        list_backups
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        if [ -z "$1" ]; then
            show_help
        else
            restore_from_backup "$1"
        fi
        ;;
esac
